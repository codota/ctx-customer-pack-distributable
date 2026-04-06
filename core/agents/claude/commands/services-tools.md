Services tools: get_service_context, get_service_dependencies, get_service_dependents, get_service, list_services

# Services Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## get_service_context

Get comprehensive context for a service combining multiple data sources. Returns service info, team ownership, dependencies, dependents, code hotspots, recent incidents, relevant ADRs, and linked GitLab issues with acceptance criteria.
PREFER: Use 'investigate_service' for the most comprehensive service analysis including all context plus documentation and flow participation in one call.
USE THIS WHEN: You need a quick service overview without the full documentation and flow context, or when profiling multiple services.

Call `mcp__tabnine-ctx-cloud__get_service_context` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to get context for (e.g., "order-service"). Supports partial matching. |

## get_service_dependencies

Get all dependencies of a service - what it depends on. Shows services it calls (HTTP/gRPC), packages it uses, databases it connects to, and message topics it publishes/subscribes to.
PREFER: Use 'investigate_service' for comprehensive view including dependencies, dependents, documentation, and flows in one call.
USE THIS WHEN: You need only the outbound dependencies (what this service relies on), not the full service context.

Call `mcp__tabnine-ctx-cloud__get_service_dependencies` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to analyze (e.g., "order-service"). Supports partial matching. |
| relationshipType | string | No | Filter to specific relationship type: "CALLS_HTTP", "CALLS_GRPC", "USES_PACKAGE", "USES_DATABASE", "PUBLISHES_TO", "SUBSCRIBES_TO". Leave empty for all dependency types. |

## get_service_dependents

Get all dependents of a service - what depends on it. Shows services that call it, services that subscribe to its topics, and packages that import it.
PREFER: Use 'blast_radius' for complete impact analysis including transitive dependents, affected flows, and teams to notify. Use 'investigate_service' if you also need the service's own dependencies.
USE THIS WHEN: You need only the inbound dependents (what calls this service), not the full impact analysis.

Call `mcp__tabnine-ctx-cloud__get_service_dependents` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to analyze (e.g., "payment-service"). Supports partial matching. |
| relationshipType | string | No | Filter to specific relationship type: "CALLS_HTTP", "CALLS_GRPC", "SUBSCRIBES_TO". Leave empty for all dependent types. |

## get_service

Get detailed information about a specific service including all its relationships. Returns service metadata, owning team, dependencies (packages, databases, services it calls), and dependents (services that call it).
PREFER: Use 'investigate_service' for comprehensive analysis that also includes documentation, business flows, and architectural context in a single call.
USE THIS WHEN: You need just the basic service info and relationships without the full investigation context, or when building custom queries.

Call `mcp__tabnine-ctx-cloud__get_service` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to look up (e.g., "order-service", "payment-api"). Supports partial matching. |

## list_services

List all services in the knowledge graph with their metadata. Returns service name, team, tier, language, framework, and purpose. Use this to get an overview of all services or filter by team/tier/language.

Call `mcp__tabnine-ctx-cloud__list_services` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| team | string | No | Filter by team name (partial match supported). Example: "Commerce", "Platform" |
| tier | string | No | Filter by service tier: "critical", "standard", "internal". |
| language | string | No | Filter by programming language: "typescript", "go", "java", "python". |
| repository | string | No | Filter by repository name (partial match supported). |
| limit | number | No | Maximum number of services to return (default 50, max 200). |