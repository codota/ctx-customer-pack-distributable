Opsgenie tools: acknowledge_opsgenie_alert, add_opsgenie_note, close_opsgenie_alert, escalate_opsgenie_alert, get_opsgenie_alert

# Opsgenie Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## acknowledge_opsgenie_alert

Acknowledge an Opsgenie alert to stop further escalations. Requires a connected and enabled Opsgenie data source.

Call `mcp__ctx-cloud__acknowledge_opsgenie_alert` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to acknowledge. |
| user | string | No | Display name of the user acknowledging the alert. |
| note | string | No | Additional note to add while acknowledging the alert. |

## add_opsgenie_note

Add a note to an existing Opsgenie alert for additional context. Requires a connected and enabled Opsgenie data source. Notes are visible on the alert timeline.

Call `mcp__ctx-cloud__add_opsgenie_note` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to add a note to. |
| note | string | Yes | The note content to add to the alert. |
| user | string | No | Display name of the user adding the note. |

## close_opsgenie_alert

Close an Opsgenie alert, marking it as resolved. Requires a connected and enabled Opsgenie data source.

Call `mcp__ctx-cloud__close_opsgenie_alert` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to close. |
| user | string | No | Display name of the user closing the alert. |
| note | string | No | Additional note to add while closing the alert. |

## escalate_opsgenie_alert

Escalate an Opsgenie alert to the next escalation level. Requires a connected and enabled Opsgenie data source.

Call `mcp__ctx-cloud__escalate_opsgenie_alert` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to escalate. |
| escalationId | string | Yes | The ID of the escalation policy to use. |
| user | string | No | Display name of the user escalating the alert. |
| note | string | No | Additional note to add while escalating the alert. |

## get_opsgenie_alert

Retrieve details of an Opsgenie alert. Use this to get alert context before taking actions like acknowledging or closing. Requires a connected and enabled Opsgenie data source.

Call `mcp__ctx-cloud__get_opsgenie_alert` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| alertId | string | Yes | The Opsgenie alert ID to retrieve. |