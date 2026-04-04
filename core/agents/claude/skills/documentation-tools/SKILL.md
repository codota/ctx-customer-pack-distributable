---
name: documentation-tools
description: >-
  Documentation tools: get_service_documentation, list_documentation,
  search_all_documentation
allowed-tools: >-
  mcp__ctx-cloud__get_service_documentation, mcp__ctx-cloud__list_documentation,
  mcp__ctx-cloud__search_all_documentation
---
# Documentation Tools

> Auto-generated from 3 exported tool(s) in the Context Engine.

## get_service_documentation

Get all documentation related to a specific service. Returns incidents that affected the service, runbooks for it, flows involving it, ADRs that mention it, and relevant security patterns.
PREFER: Use 'investigate_service' for comprehensive service analysis including documentation, dependencies, ownership, and architectural context in one call.
USE THIS WHEN: You need only the documentation artifacts without the full service context, or when compiling documentation for multiple services.

Call `mcp__ctx-cloud__get_service_documentation` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to find documentation for (e.g., "order-service", "payment-api"). Supports partial matching. |
| limit | number | No | Maximum number of results per doc type (default 5 each). |

## list_documentation

List all indexed documentation with optional filters. Returns incidents, ADRs, runbooks, flows, and security patterns. Use this to browse available documentation or filter by type/severity.

Call `mcp__ctx-cloud__list_documentation` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| docType | string | No | Filter by documentation type: "Incident", "ADR", "Runbook", "Flow", "CriticalFlow", or "SecurityPattern". Leave empty for all types. |
| severity | string | No | Filter by severity (for incidents and security patterns): "critical", "high", "medium", "low", "SEV-1", "SEV-2", "SEV-3". |
| status | string | No | Filter by status (for ADRs): "Accepted", "Proposed", "Deprecated", "Superseded". |
| limit | number | No | Maximum number of results to return (default 30). |

## search_all_documentation

Unified search across all documentation types - incidents, ADRs, runbooks, flows, and security patterns. Returns results from all doc types ranked by relevance. Use this when you need to find any documentation related to a topic.

Call `mcp__ctx-cloud__search_all_documentation` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query - can be a keyword, service name, error message, or topic. Searches across titles, descriptions, and content of all doc types. |
| docTypes | string | No | Comma-separated list of doc types to include. Options: "Incident,ADR,Runbook,Flow,SecurityPattern". Leave empty to search all types. |
| limit | number | No | Maximum number of results to return (default 20). |
