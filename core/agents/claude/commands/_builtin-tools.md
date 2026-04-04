_builtin tools: get_coding_guidelines, get_cve_resolution_status, query_entities, query_symbols, search_knowledge, search_skills

# _builtin Tools

> Auto-generated from 6 exported tool(s) in the Context Engine.

## get_coding_guidelines

Retrieve coding guidelines and best practices from the knowledge base. Use this tool to get team-specific guidelines for code review and development standards.

Call `mcp__ctx-cloud__get_coding_guidelines` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter guidelines by category (e.g., "security", "error-handling", "code-quality") |
| severity | string | No | Filter by severity level (info, warning, error, critical) |
| search | string | No | Search guidelines by name or description |
| take | number | No | Maximum number of guidelines to return (default 100) |

## get_cve_resolution_status

Query CVE resolution status across repositories. Returns CVEResolution entities showing how each CVE was resolved (VEX attestation, auto-fix PR, or human escalation) along with the current status and resolution artifacts.

Call `mcp__ctx-cloud__get_cve_resolution_status` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| cveId | string | Yes | CVE identifier to look up (e.g., "CVE-2020-8203"). Returns all resolutions for this CVE across repositories. |
| repository | string | No | Optional repository filter (e.g., "acme/order-service"). If provided, returns only the resolution for that specific repository. |
| status | string | No | Optional status filter (resolved, fix_pending_review, fix_merged, escalated, failed) |
| limit | number | No | Maximum number of results to return (default 25) |

## query_entities

Query the knowledge graph for entities and their relationships using Cypher. Returns entities matching the specified type and optional filters.

Call `mcp__ctx-cloud__query_entities` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| entityType | string | Yes | The type of entity to query (e.g., "Service", "CodePattern", "Library") |
| namePattern | string | No | Optional pattern to match entity names (supports wildcards with *) |
| limit | number | No | Maximum number of results to return (default 25) |

## query_symbols

Query extracted code symbols from repositories. Returns interfaces, structs, classes, functions, and their fields/properties extracted via LSP analysis. Use this to discover configuration APIs, type definitions, and code structure across multiple repositories in a workspace.

Call `mcp__ctx-cloud__query_symbols` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| dataSourceIds | array | No | List of data source IDs to query. If not provided, queries all data sources accessible to the tenant. Get data source IDs from the workspace configuration. |
| kinds | array | No | Symbol kinds to include. Options: interface, struct, class, enum, type, function, method, property, field. Default returns all kinds. |
| namePattern | string | No | Pattern to filter symbol names. Supports wildcards with *. Examples: "*Options*" matches all options interfaces, "Rate*" matches symbols starting with Rate. |
| includeChildren | boolean | No | If true, include nested symbols (fields, methods inside classes/interfaces). If false (default), only return top-level symbols. |
| limit | number | No | Maximum number of results to return (default 100, max 1000) |

## search_knowledge

Search the knowledge graph for entities and information using semantic similarity. Use this tool to find relevant context, code patterns, documentation, or any other knowledge stored in the system.

Call `mcp__ctx-cloud__search_knowledge` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | The search query - describe what you're looking for |
| entityTypes | string | No | Comma-separated list of entity types to filter by (e.g., "CodePattern,Documentation") |
| limit | number | No | Maximum number of results to return (default 10) |
| minSimilarity | number | No | Minimum similarity score (0-1) for results (default 0.7) |

## search_skills

Search for organizational skills learned from past successful agent runs. Skills are reusable patterns that describe how to accomplish specific tasks. Use this tool at the start of a task to find relevant approaches and best practices that have worked for similar tasks in the past.

Call `mcp__ctx-cloud__search_skills` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Describe what you're trying to accomplish |
| limit | number | No | Maximum number of skills to return (default 5) |
| minSuccessRate | number | No | Minimum success rate filter 0-1 (default 0.3) |
| status | string | No | Comma-separated list of status filters (approved, candidate, deprecated). Default "approved,candidate" |