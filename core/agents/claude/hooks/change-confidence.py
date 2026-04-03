#!/usr/bin/env python3
"""
Change Confidence Hook (PreToolUse: Bash)

Calculates a confidence score for staged changes before commit operations.
Warns about risky changes that need careful review.

Credentials: CTX_API_URL and CTX_API_KEY from environment variables.
Never reads secrets from CLI arguments.
Always exits 0 — never blocks the agent.
"""

import json
import os
import subprocess
import sys
import urllib.request
import urllib.error

CTX_API_URL = os.environ.get("CTX_API_URL", "").rstrip("/")
CTX_API_KEY = os.environ.get("CTX_API_KEY", "")
TIMEOUT = 5  # seconds
MIN_SCORE = 75  # warn below this


def get_staged_files() -> list[str]:
    """Get list of staged files from git."""
    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True, text=True, timeout=5,
        )
        return [f for f in result.stdout.strip().splitlines() if f]
    except Exception:
        return []


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
        command = tool_input.get("command", "")

        # Only intercept git commit commands
        if "git" not in command or "commit" not in command:
            print(json.dumps({"continue": True}))
            return

        staged = get_staged_files()
        if not staged:
            print(json.dumps({"continue": True}))
            return

        result = call_mcp_tool(
            "get_change_confidence",
            {"files": ",".join(staged)},
        )

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

            print(
                json.dumps(
                    {
                        "continue": True,
                        "hookSpecificOutput": {
                            "hookEventName": "PreToolUse",
                            "additionalContext": f"## Change Confidence\n\n{text}",
                        },
                    }
                )
            )
        else:
            print(json.dumps({"continue": True}))

    except Exception:
        print(json.dumps({"continue": True}))


if __name__ == "__main__":
    main()
