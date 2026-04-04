#!/usr/bin/env python3
"""
Stdio MCP server for ctx-onboard CLI.

Exposes ctx-onboard commands as MCP tools so agents can drive the
7-step onboarding methodology without Bash permission prompts.

Reads ctx-settings.yaml and injects into env so ctx-onboard picks them up.
"""

import json
import os
import subprocess
import sys
from datetime import datetime


def load_settings():
    """Load ctx-settings.yaml into env if it exists."""
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


SERVER_NAME = "ctx-onboard"
SERVER_VERSION = "0.1.0"

TOOLS = [
    {
        "name": "onboard_step_0",
        "description": "Initialize onboarding: validate CTX connectivity and detect server capabilities (credential types, agent kinds, extension support).",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_step_1",
        "description": "Build testing lab: analyze a repository and generate a test plan with categorized test cases.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "repo_path": {"type": "string", "description": "Path to the repository to analyze"},
            },
            "required": ["repo_path"],
        },
    },
    {
        "name": "onboard_step_2_start",
        "description": "Start loading project data via ctx-loader (runs in background). Returns immediately.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "manifest": {"type": "string", "description": "Manifest file path", "default": "ctx-loader.yaml"},
            },
        },
    },
    {
        "name": "onboard_step_2_status",
        "description": "Check the status of a running data load (step 2). Returns loading/completed/failed.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_step_3_get_questions",
        "description": "Get the test questions for baseline scoring (no MCP). Agent should answer without using Context Engine tools.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_step_3_submit",
        "description": "Submit baseline answers (no MCP) for scoring.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "responses_file": {"type": "string", "description": "Path to JSON file with answers"},
            },
            "required": ["responses_file"],
        },
    },
    {
        "name": "onboard_step_4_get_questions",
        "description": "Get the test questions for MCP-assisted baseline. Agent should answer using Context Engine MCP tools.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_step_4_submit",
        "description": "Submit MCP-assisted answers for scoring and comparison against step 3.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "responses_file": {"type": "string", "description": "Path to JSON file with answers"},
            },
            "required": ["responses_file"],
        },
    },
    {
        "name": "onboard_step_5",
        "description": "Domain enrichment: analyze repository for domain concepts, build domain model, and load into Context Engine.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "repo_path": {"type": "string", "description": "Path to the repository to analyze"},
            },
            "required": ["repo_path"],
        },
    },
    {
        "name": "onboard_step_6",
        "description": "Score test responses with domain enrichment active. Produces 3-way comparison (no MCP vs MCP vs MCP+domain).",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_step_7",
        "description": "Generate a phased rollout plan based on measured improvements.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_status",
        "description": "Show overall onboarding progress — which steps are completed, in progress, or pending.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "onboard_query_search",
        "description": "Search the Context Engine knowledge graph (semantic search).",
        "inputSchema": {
            "type": "object",
            "properties": {
                "terms": {"type": "string", "description": "Search terms"},
                "limit": {"type": "number", "description": "Max results", "default": 10},
            },
            "required": ["terms"],
        },
    },
    {
        "name": "onboard_query_entities",
        "description": "List or search entities in the knowledge graph.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "type": {"type": "string", "description": "Entity type (e.g. Service, CodeClass)"},
                "search": {"type": "string", "description": "Search by name"},
                "limit": {"type": "number", "description": "Max results", "default": 20},
            },
        },
    },
]


LOG_DIR = os.path.join(os.getcwd(), ".ctx-logs")
MAX_LOG_FILES = 50


def write_log(tool_name: str, cmd: list[str], exit_code: int, stdout: str, stderr: str):
    """Write full CLI output to .ctx-logs/ for support debugging."""
    try:
        os.makedirs(LOG_DIR, exist_ok=True)
        ts = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
        path = os.path.join(LOG_DIR, f"ctx-onboard-{tool_name}-{ts}.log")
        with open(path, "w") as f:
            f.write(f"timestamp: {datetime.now().isoformat()}\n")
            f.write(f"command: {' '.join(cmd)}\n")
            f.write(f"exit_code: {exit_code}\n")
            f.write(f"--- stdout ---\n{stdout}\n")
            if stderr:
                f.write(f"--- stderr ---\n{stderr}\n")
        # Rotate: keep only MAX_LOG_FILES most recent
        files = sorted(
            [f for f in os.listdir(LOG_DIR) if f.startswith("ctx-onboard-")],
        )
        for old in files[:-MAX_LOG_FILES]:
            os.remove(os.path.join(LOG_DIR, old))
    except Exception:
        pass  # Logging must never break the tool call


def run_cli(args: list[str], timeout: int = 120) -> dict:
    """Run ctx-onboard with args and return parsed JSON output."""
    load_settings()  # Re-read each time — ctx-settings.yaml may be created mid-session
    cmd = ["ctx-onboard"] + args + ["--json"]
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=timeout, cwd=os.getcwd()
        )
        # Log full output for support before parsing
        write_log(args[0] if args else "unknown", cmd, result.returncode, result.stdout, result.stderr)
        output = result.stdout.strip() or result.stderr.strip()
        try:
            return json.loads(output)
        except json.JSONDecodeError:
            return {"output": output, "exitCode": result.returncode}
    except subprocess.TimeoutExpired:
        return {"error": f"Command timed out after {timeout}s"}
    except FileNotFoundError:
        return {"error": "ctx-onboard not found. Install with: curl -fsSL .../install.sh | bash -s -- --package all --agent claude"}
    except Exception as e:
        return {"error": str(e)}


def slim_step_0(data: dict) -> dict:
    """Extract what the agent needs from step-0: connectivity + capability summary."""
    caps = data.get("capabilities", {})
    agents = caps.get("availableAgentKinds", [])
    return {
        "status": "connected" if caps else "unknown",
        "supportedCredentialTypes": caps.get("supportedCredentialTypes", []),
        "supportedDataSourceTypes": caps.get("supportedDataSourceTypes", []),
        "extensionInstallAvailable": caps.get("extensionInstallAvailable", False),
        "agentCount": len(agents),
        "agentNames": [a.get("name") for a in agents],
    }


def slim_status(data: dict) -> dict:
    """Extract step progress from status — drop checkpoint details."""
    steps = data.get("steps", data.get("progress", {}))
    if isinstance(steps, list):
        return {"steps": [{"step": s.get("step"), "status": s.get("status"), "completedAt": s.get("completedAt")} for s in steps]}
    if isinstance(steps, dict):
        return {"steps": {k: v.get("status") if isinstance(v, dict) else v for k, v in steps.items()}}
    # Fallback: return top-level keys only
    return {k: v for k, v in data.items() if k in ("currentStep", "status", "steps", "progress", "error")}


def handle_tool_call(name: str, args: dict) -> dict:
    """Map MCP tool name to ctx-onboard CLI invocation."""
    if name == "onboard_step_0":
        return slim_step_0(run_cli(["step-0"]))

    elif name == "onboard_step_1":
        cmd = ["step-1", "--repo-path", args["repo_path"]]
        return run_cli(cmd)

    elif name == "onboard_step_2_start":
        cmd = ["step-2", "--manifest", args.get("manifest", "ctx-loader.yaml")]
        return run_cli(cmd, timeout=300)

    elif name == "onboard_step_2_status":
        return run_cli(["step-2", "--status"])

    elif name == "onboard_step_3_get_questions":
        return run_cli(["step-3"])

    elif name == "onboard_step_3_submit":
        return run_cli(["step-3", "--responses", args["responses_file"]])

    elif name == "onboard_step_4_get_questions":
        return run_cli(["step-4"])

    elif name == "onboard_step_4_submit":
        return run_cli(["step-4", "--responses", args["responses_file"]])

    elif name == "onboard_step_5":
        return run_cli(["step-5", "--repo-path", args["repo_path"]], timeout=300)

    elif name == "onboard_step_6":
        return run_cli(["step-6"])

    elif name == "onboard_step_7":
        return run_cli(["step-7"])

    elif name == "onboard_status":
        return slim_status(run_cli(["status"]))

    elif name == "onboard_query_search":
        cmd = ["query", "search", args["terms"]]
        if args.get("limit"): cmd += ["--limit", str(args["limit"])]
        return run_cli(cmd)

    elif name == "onboard_query_entities":
        cmd = ["query", "entities"]
        if args.get("type"): cmd += ["--type", args["type"]]
        if args.get("search"): cmd += ["--search", args["search"]]
        if args.get("limit"): cmd += ["--limit", str(args["limit"])]
        return run_cli(cmd)

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
        return None

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
