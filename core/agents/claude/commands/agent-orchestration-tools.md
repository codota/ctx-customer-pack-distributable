Agent orchestration tools: get_agent_run_output, get_agent_run_status, invoke_agent, list_agent_kinds

# Agent orchestration Tools

> Auto-generated from 4 exported tool(s) in the Context Engine.

## get_agent_run_output

Get the output and entities produced by a completed agent run. Returns the raw output from the agent and optionally the entities it created in the knowledge graph.
Use this after an agent run completes (status: completed) to retrieve its results.

Call `mcp__tabnine-ctx-cloud__get_agent_run_output` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| agentRunId | string | Yes | The agent run ID returned by invoke_agent. |
| includeEntities | boolean | No | If true, also return the entities created by this agent run. Defaults to false. |

## get_agent_run_status

Get the current status of an agent run. Returns status (queued, running, completed, failed, cancelled), timestamps, and any error information.
Use this to monitor the progress of an agent started with invoke_agent.

Call `mcp__tabnine-ctx-cloud__get_agent_run_status` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| agentRunId | string | Yes | The agent run ID returned by invoke_agent. |

## invoke_agent

Trigger an agent run by name or ID. The agent will execute asynchronously and you can check its progress using get_agent_run_status.
Use this to run discovery agents (flow-discovery-agent, service-discovery-agent, etc.) or any other agent defined in the system.
Returns an agentRunId that can be used to track progress and retrieve results.

Call `mcp__tabnine-ctx-cloud__invoke_agent` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| agentKindName | string | No | Name of the agent to run (e.g., "flow-discovery-agent", "service-discovery-agent"). Either agentKindName or agentKindId is required. |
| agentKindId | string | No | UUID of the agent to run. Either agentKindName or agentKindId is required. |
| dataSourceId | string | No | Optional data source (repository) ID to analyze. Required for most discovery agents. |
| workspaceId | string | No | Optional workspace ID for scoping the agent's output. |
| input | object | No | Additional input parameters for the agent, as defined in its inputSchema. These are agent-specific parameters (e.g., batchSize, repositoryPath). |

## list_agent_kinds

List all available agents (agent types) in the system. Returns agent metadata including name, description, input schema, and status.
Use this to discover what agents are available before invoking them with invoke_agent.

Call `mcp__tabnine-ctx-cloud__list_agent_kinds` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| enabled | boolean | No | Filter by enabled status. If true, only return enabled agents. If false, only return disabled agents. If not provided, return all. |
| interactive | boolean | No | Filter by interactive mode. If true, only return interactive agents. If false, only return non-interactive agents. |