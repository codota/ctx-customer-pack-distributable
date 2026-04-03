---
name: pagerduty-tools
description: >-
  Pagerduty tools: acknowledge_pagerduty_incident, add_pagerduty_note,
  resolve_pagerduty_incident
allowed-tools: 'Bash(ctx-cli:*)'
---
# Pagerduty Tools

> Auto-generated from 3 exported tool(s) in the Context Engine.

## acknowledge_pagerduty_incident

Acknowledge a PagerDuty incident. Requires a connected and enabled PagerDuty data source. The requesterEmail must match a valid PagerDuty user.

```bash
ctx-cli mcp call acknowledge_pagerduty_incident -p incidentId=<string> -p requesterEmail=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| incidentId | string | Yes | The PagerDuty incident ID to acknowledge (e.g., "P1234567"). |
| requesterEmail | string | Yes | Email address of the user acknowledging the incident. Must be a valid PagerDuty user email. |

## add_pagerduty_note

Add a note to an existing PagerDuty incident. Requires a connected and enabled PagerDuty data source. Notes are visible on the incident timeline.

```bash
ctx-cli mcp call add_pagerduty_note -p incidentId=<string> -p content=<string> -p requesterEmail=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| incidentId | string | Yes | The PagerDuty incident ID to add a note to (e.g., "P1234567"). |
| content | string | Yes | The note content to add to the incident. |
| requesterEmail | string | Yes | Email address of the user adding the note. Must be a valid PagerDuty user email. |

## resolve_pagerduty_incident

Resolve a PagerDuty incident. Requires a connected and enabled PagerDuty data source. The requesterEmail must match a valid PagerDuty user. Optionally include a resolution note.

```bash
ctx-cli mcp call resolve_pagerduty_incident -p incidentId=<string> -p requesterEmail=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| incidentId | string | Yes | The PagerDuty incident ID to resolve (e.g., "P1234567"). |
| requesterEmail | string | Yes | Email address of the user resolving the incident. Must be a valid PagerDuty user email. |
| resolution | string | No | Optional resolution summary describing how the incident was resolved. |
