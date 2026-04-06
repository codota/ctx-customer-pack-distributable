---
name: ownership-tools
description: >-
  Ownership tools: get_all_teams, get_code_reviewers, get_incident_contacts,
  get_service_ownership, get_team_services
tags:
  - ownership
  - auto-generated
group: ownership
mcp-tools:
  - get_all_teams
  - get_code_reviewers
  - get_incident_contacts
  - get_service_ownership
  - get_team_services
---
# Ownership Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## get_all_teams

Get all teams in the organization with their contact information and services/packages they own. Use this to understand team structure and find the right team to contact.

Call `mcp__tabnine-ctx-cloud__get_all_teams` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| includeServices | boolean | No | Include list of services owned by each team. Default: true. |

## get_code_reviewers

Get suggested code reviewers for a service or file path. Combines CODEOWNERS data with git expertise analysis to suggest the best reviewers. Returns team owners, recent contributors, and domain experts.

Call `mcp__tabnine-ctx-cloud__get_code_reviewers` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| path | string | Yes | File path or service name to find reviewers for (e.g., "services/payment-service/" or "checkout.service.ts"). |

## get_incident_contacts

Get escalation contacts for an incident affecting a service or feature. Returns the primary team to contact, escalation paths, related runbooks, and past incidents for context.
PREFER: Use 'incident_response' for complete incident support - includes contacts, runbooks, past incidents, and ownership details in one call.
USE THIS WHEN: You need only the contact/escalation info, or when you already have runbook and incident context from other sources.

Call `mcp__tabnine-ctx-cloud__get_incident_contacts` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| service | string | Yes | Service name that is affected (e.g., "order-service", "checkout"). Can also be a feature name like "checkout" or "payments". |
| severity | string | No | Incident severity: "SEV-1" (critical), "SEV-2" (high), "SEV-3" (medium). Affects escalation recommendations. |

## get_service_ownership

Get comprehensive ownership and contact information for a service. Returns the owning team, Slack channel, oncall contact, PagerDuty escalation, service tier, compliance requirements, and related runbooks.
PREFER: Use 'incident_response' during incidents - it includes ownership plus escalation paths, runbooks, and similar past incidents in one call. Use 'investigate_service' for general investigation - includes ownership context.
USE THIS WHEN: You specifically need ownership/contact info without incident context, or when building team directory lookups.

Call `mcp__tabnine-ctx-cloud__get_service_ownership` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to look up (e.g., "order-service" or "payment-service"). Supports partial matching. |

## get_team_services

Get all services and packages owned by a team. Returns services with their tier, packages maintained, and team contacts. Use this to understand a team's scope or find services by team.

Call `mcp__tabnine-ctx-cloud__get_team_services` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| teamName | string | Yes | Team name (e.g., "Commerce Team", "Platform", "Payments"). Supports partial matching. |
