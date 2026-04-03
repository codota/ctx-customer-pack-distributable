---
name: architecture-tools
description: >-
  Architecture tools: get_runbook, get_security_patterns, search_adrs,
  search_flows, search_incidents
tags:
  - architecture
  - auto-generated
group: architecture
mcp-tools:
  - get_runbook
  - get_security_patterns
  - search_adrs
  - search_flows
  - search_incidents
---
# Architecture Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## get_runbook

Get a runbook for a specific service or operational scenario. Returns investigation steps, mitigation commands, escalation paths, and related context.
PREFER: Use 'incident_response' during incidents - it includes the runbook plus escalation contacts, similar incidents, and ownership in one call.
USE THIS WHEN: You need just the runbook steps without the incident context, or when referencing runbooks outside of an active incident.

```bash
ctx-cli mcp call get_runbook -p service=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| service | string | Yes | Service name or scenario (e.g., "order-service", "checkout-failures"). |

## get_security_patterns

Get security patterns and anti-patterns learned from past incidents. Returns code examples of what NOT to do and the correct approach.
PREFER: Use 'incident_response' during active incidents - includes relevant security patterns plus runbooks, escalation contacts, and similar incidents.
USE THIS WHEN: You need to browse security patterns for code review or education, without the context of a specific incident or service.

```bash
ctx-cli mcp call get_security_patterns  -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Security category to search for (e.g., "rate-limiting", "authentication", "injection", "authorization"). Leave empty to get all patterns. |
| query | string | No | Search query - can be a topic or keyword (e.g., "X-Forwarded-For", "JWT"). |

## search_adrs

Search Architecture Decision Records (ADRs) by keyword or topic. Finds ADRs that match the query in their title, decision, rationale, or alternatives. Use this to understand why architectural decisions were made or to find relevant context for new decisions.
PREFER: Use 'code_migration' when researching ADRs for a specific migration. Use 'understand_flow' when researching ADRs for a specific business flow.
USE THIS WHEN: You need to browse ADRs by topic without specific migration or flow context, or when researching architectural patterns broadly.

```bash
ctx-cli mcp call search_adrs -p query=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query - can be a keyword (e.g., "RabbitMQ"), topic (e.g., "messaging"), or question (e.g., "why message queue"). Searches title, decision, and rationale. |
| status | string | No | Filter by ADR status: "accepted", "proposed", "deprecated", "superseded". Leave empty to search all statuses. |

## search_flows

Search for documented business flows and workflows by keyword or service. Returns flow details including steps, services involved, and related context.
PREFER: Use 'understand_flow' for complete flow analysis including ownership, runbooks, past incidents, and architectural decisions in one call.
USE THIS WHEN: You need to search across multiple flows by keyword, or when browsing available flows without full operational context.

```bash
ctx-cli mcp call search_flows -p query=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query - can be a flow name (e.g., "checkout"), feature (e.g., "payment"), or service (e.g., "order-service"). Searches title, purpose, and steps. |

## search_incidents

Search past incidents by keyword, service, or symptom. Returns incidents with root causes, lessons learned, and affected services.
PREFER: Use 'incident_response' during active incidents - it provides escalation contacts, runbooks, and similar incidents for a specific service.
USE THIS WHEN: You need to search across all incidents by keyword/symptom, or when researching historical patterns not tied to a specific service.

```bash
ctx-cli mcp call search_incidents -p query=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query - can be a keyword (e.g., "timeout"), service (e.g., "checkout"), or symptom (e.g., "5xx errors"). Searches title, root cause, and symptoms. |
| severity | string | No | Filter by severity: "SEV-1", "SEV-2", "SEV-3", "High", "Medium", "Low". Leave empty to search all severities. |
| service | string | No | Filter to incidents affecting a specific service. |
