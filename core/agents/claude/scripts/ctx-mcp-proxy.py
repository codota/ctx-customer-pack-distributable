#!/usr/bin/env python3
"""
Stdio MCP Proxy for Context Engine.

Bridges Claude Code's stdio-based MCP protocol to the Context Engine's
HTTP/SSE endpoint.

Input:  JSON-RPC on stdin (from Claude Code)
Output: JSON-RPC on stdout (to Claude Code)
Forward: All messages to CTX_API_URL/mcp via HTTP

Credentials: from ctx-settings.yaml in cwd, or CTX_API_URL/CTX_API_KEY env vars.
Never reads secrets from CLI arguments.
"""

import json
import os
import sys
import urllib.request
import urllib.error


def load_settings():
    """Load ctx-settings.yaml into env if it exists (same convention as CLIs)."""
    settings_path = os.path.join(os.getcwd(), "ctx-settings.yaml")
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
    """Get credentials, re-reading ctx-settings.yaml each time (handles late creation)."""
    load_settings()
    return (
        os.environ.get("CTX_API_URL", "").rstrip("/"),
        os.environ.get("CTX_API_KEY", ""),
    )

session_id = None


def send_to_remote(payload: dict) -> str | None:
    """Send a JSON-RPC message to the remote MCP server."""
    global session_id

    api_url, api_key = get_credentials()
    if not api_url or not api_key:
        return json.dumps({
            "jsonrpc": "2.0",
            "id": payload.get("id"),
            "error": {"code": -32600, "message": "CTX_API_URL and CTX_API_KEY must be set. Create ctx-settings.yaml with your credentials."},
        })

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


def main():
    """Read JSON-RPC from stdin, forward to CTX, write response to stdout."""
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            payload = json.loads(line)
        except json.JSONDecodeError:
            continue

        response = send_to_remote(payload)
        if response:
            sys.stdout.write(response + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
