#!/usr/bin/env python3
"""
Stdio MCP server for ctx-loader CLI.

Exposes ctx-loader commands as MCP tools so agents can call them
directly without Bash permission prompts or env var prefixes.

Reads ctx-settings.yaml automatically (ctx-loader handles this).
"""

import json
import os
import subprocess
import sys

SERVER_NAME = "ctx-loader"
SERVER_VERSION = "0.1.0"

TOOLS = [
    {
        "name": "loader_init",
        "description": "Generate a ctx-loader manifest from a template. Creates ctx-loader.yaml with the project configuration.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "template": {"type": "string", "description": "Template name: minimal, github-jira-slack, gitlab-linear-pagerduty", "default": "minimal"},
                "output": {"type": "string", "description": "Output file path", "default": "ctx-loader.yaml"},
                "owner": {"type": "string", "description": "GitHub org/owner (resolves ${GITHUB_ORG} in template)"},
                "repo": {"type": "string", "description": "GitHub repo name (resolves ${GITHUB_REPO} in template)"},
                "resolve": {"type": "boolean", "description": "Resolve all env vars and ctx-settings.yaml values in the template"},
            },
        },
    },
    {
        "name": "loader_validate",
        "description": "Validate a ctx-loader manifest (schema check + CTX API connectivity test).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "manifest": {"type": "string", "description": "Manifest file path", "default": "ctx-loader.yaml"},
            },
        },
    },
    {
        "name": "loader_load",
        "description": "Execute full data load pipeline. Loads data from configured sources into the Context Engine.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "manifest": {"type": "string", "description": "Manifest file path", "default": "ctx-loader.yaml"},
            },
            "required": ["manifest"],
        },
    },
    {
        "name": "loader_status",
        "description": "Show current pipeline status. Use summary=true for a compact view.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "summary": {"type": "boolean", "description": "Compact status (omit internal details)", "default": True},
            },
        },
    },
    {
        "name": "loader_resume",
        "description": "Resume a failed or interrupted load from the last checkpoint.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "manifest": {"type": "string", "description": "Manifest file path", "default": "ctx-loader.yaml"},
            },
            "required": ["manifest"],
        },
    },
    {
        "name": "loader_diagnose",
        "description": "Diagnose failures in the latest load run. Returns structured error details with remediation steps.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "loader_collect_logs",
        "description": "Collect debug bundle for support. Returns checkpoint, onboarding state, and loader logs with secrets redacted.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "loader_query_search",
        "description": "Semantic search across the Context Engine knowledge graph.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "terms": {"type": "string", "description": "Search terms"},
                "limit": {"type": "number", "description": "Max results", "default": 10},
                "types": {"type": "string", "description": "Comma-separated entity types to filter"},
            },
            "required": ["terms"],
        },
    },
    {
        "name": "loader_query_entities",
        "description": "List or search entities in the knowledge graph.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "type": {"type": "string", "description": "Entity type (e.g. Service, CodeClass, Library)"},
                "search": {"type": "string", "description": "Search by name"},
                "limit": {"type": "number", "description": "Max results", "default": 20},
            },
        },
    },
    {
        "name": "loader_query_entity",
        "description": "Get a specific entity by ID.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "id": {"type": "string", "description": "Entity ID"},
            },
            "required": ["id"],
        },
    },
    {
        "name": "loader_reset",
        "description": "Reset CTX tenant to factory settings (deletes all data). Requires confirmation.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "confirm": {"type": "boolean", "description": "Must be true to proceed"},
            },
            "required": ["confirm"],
        },
    },
]


def run_cli(args: list[str], timeout: int = 120) -> dict:
    """Run ctx-loader with args and return parsed JSON output."""
    cmd = ["ctx-loader"] + args + ["--json"]
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout, cwd=os.getcwd()
        )
        output = result.stdout.strip() or result.stderr.strip()
        try:
            return json.loads(output)
        except json.JSONDecodeError:
            return {"output": output, "exitCode": result.returncode}
    except subprocess.TimeoutExpired:
        return {"error": f"Command timed out after {timeout}s"}
    except FileNotFoundError:
        return {"error": "ctx-loader not found. Install with: curl -fsSL .../install.sh | bash -s -- --package loader --agent claude"}
    except Exception as e:
        return {"error": str(e)}


def handle_tool_call(name: str, args: dict) -> dict:
    """Map MCP tool name to ctx-loader CLI invocation."""
    if name == "loader_init":
        cmd = ["init"]
        if args.get("template"): cmd += ["--template", args["template"]]
        if args.get("output"): cmd += ["--output", args["output"]]
        if args.get("owner"): cmd += ["--owner", args["owner"]]
        if args.get("repo"): cmd += ["--repo", args["repo"]]
        if args.get("resolve"): cmd += ["--resolve"]
        return run_cli(cmd)

    elif name == "loader_validate":
        cmd = ["validate"]
        if args.get("manifest"): cmd += ["--manifest", args["manifest"]]
        return run_cli(cmd)

    elif name == "loader_load":
        cmd = ["load", "--manifest", args.get("manifest", "ctx-loader.yaml")]
        return run_cli(cmd, timeout=600)

    elif name == "loader_status":
        cmd = ["status"]
        if args.get("summary", True): cmd += ["--summary"]
        return run_cli(cmd)

    elif name == "loader_resume":
        cmd = ["resume", "--manifest", args.get("manifest", "ctx-loader.yaml")]
        return run_cli(cmd, timeout=600)

    elif name == "loader_diagnose":
        return run_cli(["diagnose"])

    elif name == "loader_collect_logs":
        return run_cli(["collect-logs"])

    elif name == "loader_query_search":
        cmd = ["query", "search", args["terms"]]
        if args.get("limit"): cmd += ["--limit", str(args["limit"])]
        if args.get("types"): cmd += ["--types", args["types"]]
        return run_cli(cmd)

    elif name == "loader_query_entities":
        cmd = ["query", "entities"]
        if args.get("type"): cmd += ["--type", args["type"]]
        if args.get("search"): cmd += ["--search", args["search"]]
        if args.get("limit"): cmd += ["--limit", str(args["limit"])]
        return run_cli(cmd)

    elif name == "loader_query_entity":
        return run_cli(["query", "entity", args["id"]])

    elif name == "loader_reset":
        if not args.get("confirm"):
            return {"error": "Reset requires confirm=true"}
        return run_cli(["reset", "--yes"])

    return {"error": f"Unknown tool: {name}"}


def handle_message(msg: dict) -> dict | None:
    """Handle a JSON-RPC message."""
    method = msg.get("method", "")
    msg_id = msg.get("id")

    if method == "initialize":
        return {
            "jsonrpc": "2.0", "id": msg_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
            },
        }

    if method == "notifications/initialized":
        return None  # No response for notifications

    if method == "tools/list":
        return {
            "jsonrpc": "2.0", "id": msg_id,
            "result": {"tools": TOOLS},
        }

    if method == "tools/call":
        params = msg.get("params", {})
        tool_name = params.get("name", "")
        tool_args = params.get("arguments", {})
        result = handle_tool_call(tool_name, tool_args)
        return {
            "jsonrpc": "2.0", "id": msg_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(result, indent=2)}],
            },
        }

    # Unknown method
    return {
        "jsonrpc": "2.0", "id": msg_id,
        "error": {"code": -32601, "message": f"Method not found: {method}"},
    }


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue

        response = handle_message(msg)
        if response:
            sys.stdout.write(json.dumps(response) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
