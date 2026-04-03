---
name: opsgenie-tools
description: >-
  Opsgenie tools: acknowledge_opsgenie_alert, add_opsgenie_note,
  close_opsgenie_alert, escalate_opsgenie_alert, get_opsgenie_alert
tags:
  - opsgenie
  - auto-generated
group: opsgenie
mcp-tools:
  - acknowledge_opsgenie_alert
  - add_opsgenie_note
  - close_opsgenie_alert
  - escalate_opsgenie_alert
  - get_opsgenie_alert
allowed-tools: 'Bash(ctx-cli:*)'
---
# Opsgenie Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## acknowledge_opsgenie_alert

Acknowledge an Opsgenie alert to stop further escalations. Requires a connected and enabled Opsgenie data source.

```bash
ctx-cli mcp call acknowledge_opsgenie_alert -p alertId=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to acknowledge. |
| user | string | No | Display name of the user acknowledging the alert. |
| note | string | No | Additional note to add while acknowledging the alert. |

## add_opsgenie_note

Add a note to an existing Opsgenie alert for additional context. Requires a connected and enabled Opsgenie data source. Notes are visible on the alert timeline.

```bash
ctx-cli mcp call add_opsgenie_note -p alertId=<string> -p note=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to add a note to. |
| note | string | Yes | The note content to add to the alert. |
| user | string | No | Display name of the user adding the note. |

## close_opsgenie_alert

Close an Opsgenie alert, marking it as resolved. Requires a connected and enabled Opsgenie data source.

```bash
ctx-cli mcp call close_opsgenie_alert -p alertId=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to close. |
| user | string | No | Display name of the user closing the alert. |
| note | string | No | Additional note to add while closing the alert. |

## escalate_opsgenie_alert

Escalate an Opsgenie alert to the next escalation level. Requires a connected and enabled Opsgenie data source.

```bash
ctx-cli mcp call escalate_opsgenie_alert -p alertId=<string> -p escalationId=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to escalate. |
| escalationId | string | Yes | The ID of the escalation policy to use. |
| user | string | No | Display name of the user escalating the alert. |
| note | string | No | Additional note to add while escalating the alert. |

## get_opsgenie_alert

Retrieve details of an Opsgenie alert. Use this to get alert context before taking actions like acknowledging or closing. Requires a connected and enabled Opsgenie data source.

```bash
ctx-cli mcp call get_opsgenie_alert -p alertId=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to retrieve. |
