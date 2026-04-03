---
name: incident-response
description: >-
  Get incident response context — runbooks, escalation contacts, recent
  incidents for a service.
tags:
  - operations
  - incident
group: composite
mcp-tools:
  - incident_response
---
# Incident Response

Pull incident response context from the knowledge graph: runbooks, escalation contacts, and recent incident history for a service.

## Usage

```bash
# Get incident response context for a service
ctx-cli mcp call incident_response -p service_name=payments-api -o json
```

The response includes:
- **Runbooks** — links and summaries of operational runbooks.
- **Escalation contacts** — on-call engineers, team leads, and escalation paths.
- **Recent incidents** — past incidents with timelines and root causes.
- **Known failure modes** — documented failure patterns and mitigations.

## Examples

```bash
# Get runbooks during an active incident
ctx-cli mcp call incident_response -p service_name=checkout-service -o json | jq '.runbooks'

# Find escalation contacts quickly
ctx-cli mcp call incident_response -p service_name=auth-service -o json | jq '.escalation_contacts'

# Review recent incidents for a service
ctx-cli mcp call incident_response -p service_name=order-service -o json | jq '.recent_incidents'
```

## When to Use

- During an active incident to find runbooks and contacts fast.
- Before on-call handoff to review recent incident history.
- When investigating recurring failures to check known failure modes.
