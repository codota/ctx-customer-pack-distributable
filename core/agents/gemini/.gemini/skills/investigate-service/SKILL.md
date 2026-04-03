---
name: investigate-service
description: >-
  Deep-dive investigation of a service — dependencies, dependents, ownership,
  ADRs, incidents.
tags:
  - architecture
  - investigation
group: composite
mcp-tools:
  - investigate_service
---
# Investigate Service

Deep-dive into any service registered in the Context Engine to understand its architecture, ownership, and operational history.

## Usage

```bash
# Full investigation of a service
ctx-cli mcp call investigate_service -p service_name=payments-api -o json
```

The response includes:
- **Dependencies** — upstream services this service calls.
- **Dependents** — downstream services that call this service.
- **Ownership** — team, on-call contacts, and escalation paths.
- **ADRs** — architecture decision records related to the service.
- **Incidents** — recent incidents involving this service.

## Examples

```bash
# Investigate before making changes
ctx-cli mcp call investigate_service -p service_name=user-auth -o json

# Pipe to jq to extract just dependencies
ctx-cli mcp call investigate_service -p service_name=order-service -o json | jq '.dependencies'

# Get ownership info for an unfamiliar service
ctx-cli mcp call investigate_service -p service_name=notification-gateway -o json | jq '.ownership'
```

## When to Use

- Before modifying a service you are unfamiliar with.
- When triaging an incident to understand service boundaries.
- To find the owning team for a service and its escalation contacts.
