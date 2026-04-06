#!/usr/bin/env python3
"""
Stdio MCP Proxy for Context Engine.

Bridges Claude Code's stdio-based MCP protocol to the Context Engine's
HTTP/SSE endpoint.

Input:  JSON-RPC on stdin (from Claude Code)
Output: JSON-RPC on stdout (to Claude Code)
Forward: All messages to CTX_API_URL/mcp via HTTP

Credentials: from .tabnine/ctx/ctx-settings.yaml in cwd, or CTX_API_URL/CTX_API_KEY env vars.
Never reads secrets from CLI arguments.
"""

import json
import os
import sys
import urllib.request
import urllib.error


def load_settings():
    """Load .tabnine/ctx/ctx-settings.yaml into env if it exists (same convention as CLIs)."""
    # Must match shared/src/paths.ts CTX_RUNTIME_ROOT
    settings_path = os.path.join(os.getcwd(), ".tabnine", "ctx", "ctx-settings.yaml")
    if not os.path.exists(settings_path):
        return
    try:
        with open(settings_path) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if ":" not in line:
                    continue
                key, _, value = line.partition(":")
                key, value = key.strip(), value.strip()
                if key and value and not os.environ.get(key):
                    os.environ[key] = value
    except Exception:
        pass


TIMEOUT = 120  # seconds per request


def get_credentials():
    """Get credentials, re-reading settings each time (handles late creation)."""
    load_settings()
    return (
        os.environ.get("CTX_API_URL", "").rstrip("/"),
        os.environ.get("CTX_API_KEY", ""),
    )

session_id = None


def ensure_remote_session():
    """Establish a remote MCP session if not already done."""
    global session_id
    if session_id:
        return
    # Send initialize to the remote server to get a session ID
    init_payload = {
        "jsonrpc": "2.0",
        "id": "__init__",
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "tabnine-ctx-cloud-proxy", "version": SERVER_VERSION},
        },
    }
    api_url, api_key = get_credentials()
    if not api_url or not api_key:
        return
    url = f"{api_url}/mcp"
    headers = {
        "Content-Type": "application/json",
        "Accept": "text/event-stream, application/json",
        "Authorization": f"Bearer {api_key}",
    }
    req = urllib.request.Request(url, data=json.dumps(init_payload).encode(), headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            sid = resp.headers.get("Mcp-Session-Id")
            if sid:
                session_id = sid
    except Exception:
        pass  # Session init failed — tool calls will try without session


def send_to_remote(payload: dict) -> str | None:
    """Send a JSON-RPC message to the remote MCP server."""
    global session_id

    api_url, api_key = get_credentials()
    if not api_url or not api_key:
        return json.dumps({
            "jsonrpc": "2.0",
            "id": payload.get("id"),
            "error": {"code": -32600, "message": "CTX_API_URL and CTX_API_KEY must be set. Create .tabnine/ctx/ctx-settings.yaml with your credentials."},
        })

    # Establish remote session on first tool call
    ensure_remote_session()

    url = f"{api_url}/mcp"
    headers = {
        "Content-Type": "application/json",
        "Accept": "text/event-stream, application/json",
        "Authorization": f"Bearer {api_key}",
    }
    if session_id:
        headers["Mcp-Session-Id"] = session_id

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers=headers,
    )

    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            # Capture session ID
            sid = resp.headers.get("Mcp-Session-Id")
            if sid:
                session_id = sid

            body = resp.read().decode()

            # Handle SSE responses
            if "text/event-stream" in resp.headers.get("Content-Type", ""):
                for line in body.splitlines():
                    if line.startswith("data: "):
                        return line[6:]
                return None

            return body

    except urllib.error.HTTPError as e:
        return json.dumps({
            "jsonrpc": "2.0",
            "id": payload.get("id"),
            "error": {"code": -32000, "message": f"HTTP {e.code}: {e.reason}"},
        })
    except Exception as e:
        return json.dumps({
            "jsonrpc": "2.0",
            "id": payload.get("id"),
            "error": {"code": -32000, "message": str(e)},
        })


SERVER_NAME = "tabnine-ctx-cloud"
SERVER_VERSION = "0.1.0"

# Static tool schemas as fallback (loaded from file bundled alongside this script).
STATIC_TOOLS: list[dict] = []
_schema_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tool-schemas.json")
if os.path.exists(_schema_path):
    try:
        with open(_schema_path) as _f:
            _raw = json.load(_f)
        for _tool in _raw.values():
            STATIC_TOOLS.append({
                "name": _tool.get("name", ""),
                "description": _tool.get("description", ""),
                "inputSchema": _tool.get("parameters", {"type": "object", "properties": {}}),
            })
    except Exception:
        pass

# Cached live tools from the remote server (populated on first tools/list with credentials).
_live_tools: list[dict] | None = None


def fetch_live_tools() -> list[dict] | None:
    """Fetch tools/list from the remote server and cache the result."""
    global _live_tools
    if _live_tools is not None:
        return _live_tools

    api_url, api_key = get_credentials()
    if not api_url or not api_key:
        return None

    try:
        ensure_remote_session()
        list_payload = {"jsonrpc": "2.0", "id": "__tools_list__", "method": "tools/list", "params": {}}
        url = f"{api_url}/mcp"
        headers = {
            "Content-Type": "application/json",
            "Accept": "text/event-stream, application/json",
            "Authorization": f"Bearer {api_key}",
        }
        if session_id:
            headers["Mcp-Session-Id"] = session_id

        req = urllib.request.Request(url, data=json.dumps(list_payload).encode(), headers=headers)
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            body = resp.read().decode()
            # Handle SSE
            if "text/event-stream" in resp.headers.get("Content-Type", ""):
                for line in body.splitlines():
                    if line.startswith("data: "):
                        data = json.loads(line[6:])
                        _live_tools = data.get("result", {}).get("tools", [])
                        return _live_tools
            else:
                data = json.loads(body)
                _live_tools = data.get("result", {}).get("tools", [])
                return _live_tools
    except Exception:
        return None


def handle_locally(payload: dict) -> str | None:
    """Handle protocol messages locally; return None to forward to remote."""
    method = payload.get("method", "")
    msg_id = payload.get("id")

    if method == "initialize":
        return json.dumps({
            "jsonrpc": "2.0", "id": msg_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
            },
        })

    if method == "notifications/initialized":
        return None  # No response needed

    if method == "tools/list":
        # Try live tools from server first (accurate), fall back to static schemas
        tools = fetch_live_tools() or STATIC_TOOLS
        return json.dumps({
            "jsonrpc": "2.0", "id": msg_id,
            "result": {"tools": tools},
        })

    # Only tools/call gets forwarded to remote
    return None


def main():
    """Read JSON-RPC from stdin, handle protocol locally, forward tool calls to CTX."""
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            payload = json.loads(line)
        except json.JSONDecodeError:
            continue

        # Handle initialize/notifications locally so server starts even without credentials
        local_response = handle_locally(payload)
        if local_response:
            sys.stdout.write(local_response + "\n")
            sys.stdout.flush()
            continue

        # Skip notifications (no id = no response expected)
        if "id" not in payload:
            continue

        response = send_to_remote(payload)
        if response:
            sys.stdout.write(response + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
