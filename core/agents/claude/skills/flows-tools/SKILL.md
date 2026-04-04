---
name: flows-tools
description: 'Flows tools: get_flow_services, get_flow, get_service_flows, list_flows'
allowed-tools: >-
  mcp__ctx-cloud__get_flow_services, mcp__ctx-cloud__get_flow,
  mcp__ctx-cloud__get_service_flows, mcp__ctx-cloud__list_flows
---
# Flows Tools

> Auto-generated from 4 exported tool(s) in the Context Engine.

## get_flow_services

Get all services involved in a flow with their roles and order. Shows the orchestrator, each service's responsibility, and the sequence of service calls.
PREFER: Use 'understand_flow' for complete flow analysis including ownership, runbooks, past incidents, and architectural decisions in one call.
USE THIS WHEN: You need just the service participation list without the full operational context, or when comparing services across multiple flows.

Call `mcp__ctx-cloud__get_flow_services` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| flowName | string | Yes | Flow name to get services for (e.g., "checkout", "payment-processing"). Supports partial matching. |

## get_flow

Get detailed information about a specific flow including all steps, services involved, compensation logic, and related incidents/ADRs.
PREFER: Use 'understand_flow' for complete flow analysis including ownership, runbooks, past incidents, and architectural decisions in one call.
USE THIS WHEN: You need just the flow definition and steps without the full operational context, or when listing multiple flows.

Call `mcp__ctx-cloud__get_flow` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| flowName | string | Yes | Flow name to look up (e.g., "checkout", "order-processing"). Supports partial matching. |

## get_service_flows

Get all flows that involve a specific service. Shows which business processes the service participates in, its role (orchestrator or participant), and the other services it collaborates with.
PREFER: Use 'investigate_service' for comprehensive service analysis including flows, dependencies, documentation, and ownership in one call. Use 'blast_radius' when assessing impact of changes to this service.
USE THIS WHEN: You need just the flow participation list without the full service context, or when mapping flows for multiple services.

Call `mcp__ctx-cloud__get_service_flows` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to find flows for (e.g., "order-service", "payment-api"). Supports partial matching. |
| limit | number | No | Maximum number of flows to return (default 15). |

## list_flows

List all business flows discovered in the codebase. Includes both CriticalFlow (discovered from code, spanning 3+ services) and Flow (documented in markdown) entities. Use this to understand the major business processes in your system.

Call `mcp__ctx-cloud__list_flows` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| flowType | string | No | Filter by flow type: "CriticalFlow" (code-discovered) or "Flow" (documented). Leave empty for both types. |
| minServices | number | No | Minimum number of services a flow must span. Default is 1. |
| repository | string | No | Filter by repository name (partial match). |
| limit | number | No | Maximum number of flows to return (default 20). |
