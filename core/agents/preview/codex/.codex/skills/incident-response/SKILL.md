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

**Get incident response context for a service**
Call `mcp__ctx-cloud__incident_response` with service_name=payments-api.

The response includes:
- **Runbooks** — links and summaries of operational runbooks.
- **Escalation contacts** — on-call engineers, team leads, and escalation paths.
- **Recent incidents** — past incidents with timelines and root causes.
- **Known failure modes** — documented failure patterns and mitigations.

## Examples

**Get incident response context for checkout-service**
Call `mcp__ctx-cloud__incident_response` with service_name=checkout-service.
**Get incident response context for auth-service**
Call `mcp__ctx-cloud__incident_response` with service_name=auth-service.
**Get incident response context for order-service**
Call `mcp__ctx-cloud__incident_response` with service_name=order-service.

## When to Use

- During an active incident to find runbooks and contacts fast.
- Before on-call handoff to review recent incident history.
- When investigating recurring failures to check known failure modes.
