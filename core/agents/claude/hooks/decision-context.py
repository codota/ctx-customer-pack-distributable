#!/usr/bin/env python3
"""
Decision Context Hook (PreToolUse: Edit|Write)

Fetches architectural context (ADRs, incidents, patterns, experts) from the
Context Engine when a file is about to be edited.

Credentials: CTX_API_URL and CTX_API_KEY from environment variables.
Never reads secrets from CLI arguments.
Always exits 0 — never blocks the agent.
"""

import json
import os
import sys
import urllib.request
import urllib.error

CTX_API_URL = os.environ.get("CTX_API_URL", "").rstrip("/")
CTX_API_KEY = os.environ.get("CTX_API_KEY", "")
TIMEOUT = 3  # seconds
MAX_CONTEXT = 2000  # chars


def call_mcp_tool(tool_name: str, params: dict) -> dict | None:
    """Call a CTX MCP tool via HTTP."""
    if not CTX_API_URL or not CTX_API_KEY:
        return None

    url = f"{CTX_API_URL}/mcp"
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {"name": tool_name, "arguments": params},
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {CTX_API_KEY}",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            body = resp.read().decode()
            # Handle SSE or plain JSON
            for line in body.splitlines():
                if line.startswith("data: "):
                    return json.loads(line[6:])
            return json.loads(body)
    except Exception:
        return None


def main():
    try:
        hook_input = json.loads(sys.stdin.read())
        tool_input = hook_input.get("tool_input", {})
        file_path = tool_input.get("file_path", "")

        if not file_path:
            print(json.dumps({"continue": True}))
            return

        result = call_mcp_tool("get_file_context", {"filePath": file_path})

        if result and "result" in result:
            content = result["result"]
            if isinstance(content, list):
                text = "\n".join(
                    item.get("text", "") for item in content if item.get("type") == "text"
                )
            elif isinstance(content, dict):
                text = content.get("text", str(content))
            else:
                text = str(content)

            text = text[:MAX_CONTEXT]

            print(
                json.dumps(
                    {
                        "continue": True,
                        "hookSpecificOutput": {
                            "hookEventName": "PreToolUse",
                            "additionalContext": f"## Context for {file_path}\n\n{text}",
                        },
                    }
                )
            )
        else:
            print(json.dumps({"continue": True}))

    except Exception:
        # Never block the agent
        print(json.dumps({"continue": True}))


if __name__ == "__main__":
    main()
