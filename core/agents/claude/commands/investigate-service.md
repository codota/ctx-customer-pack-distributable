Deep-dive investigation of a service — dependencies, dependents, ownership, ADRs, incidents.

# Investigate Service

Deep-dive into any service registered in the Context Engine to understand its architecture, ownership, and operational history.

## Usage

**Full investigation of a service**
Call `mcp__ctx-cloud__investigate_service` with service_name=payments-api.

The response includes:
- **Dependencies** — upstream services this service calls.
- **Dependents** — downstream services that call this service.
- **Ownership** — team, on-call contacts, and escalation paths.
- **ADRs** — architecture decision records related to the service.
- **Incidents** — recent incidents involving this service.

## Examples

**Investigate before making changes**
Call `mcp__ctx-cloud__investigate_service` with service_name=user-auth.
**Pipe to jq to extract just dependencies**
Call `mcp__ctx-cloud__investigate_service` with service_name=order-service.
**Get ownership info for an unfamiliar service**
Call `mcp__ctx-cloud__investigate_service` with service_name=notification-gateway.

## When to Use

- Before modifying a service you are unfamiliar with.
- When triaging an incident to understand service boundaries.
- To find the owning team for a service and its escalation contacts.