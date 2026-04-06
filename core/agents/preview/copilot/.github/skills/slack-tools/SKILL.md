---
name: slack-tools
description: 'Slack tools: post_slack_message, update_slack_message'
tags:
  - slack
  - auto-generated
group: slack
mcp-tools:
  - post_slack_message
  - update_slack_message
---
# Slack Tools

> Auto-generated from 2 exported tool(s) in the Context Engine.

## post_slack_message

Post a message to a Slack channel. Requires a connected and enabled Slack data source. Uses the Slack chat.postMessage API. Supports threading via thread_ts parameter.

Call `mcp__tabnine-ctx-cloud__post_slack_message` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| channel | string | Yes | Slack channel ID (e.g., "C1234567890") or channel name (e.g., "#general"). |
| text | string | Yes | The message text to post. Supports Slack mrkdwn formatting. |
| thread_ts | string | No | Timestamp of the parent message to reply in a thread. Leave empty to post as a new message. |

## update_slack_message

Update an existing Slack message. Requires a connected and enabled Slack data source. Uses the Slack chat.update API.

Call `mcp__tabnine-ctx-cloud__update_slack_message` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| channel | string | Yes | Slack channel ID containing the message (e.g., "C1234567890"). |
| ts | string | Yes | Timestamp of the message to update. |
| text | string | Yes | The new message text. Supports Slack mrkdwn formatting. |
