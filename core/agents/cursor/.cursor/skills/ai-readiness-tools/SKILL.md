---
name: ai-readiness-tools
description: 'Ai readiness tools: get_ai_readiness_history, get_ai_readiness'
tags:
  - ai-readiness
  - auto-generated
group: ai-readiness
mcp-tools:
  - get_ai_readiness_history
  - get_ai_readiness
---
# Ai readiness Tools

> Auto-generated from 2 exported tool(s) in the Context Engine.

## get_ai_readiness_history

Get the historical AI Readiness snapshots for a repository. Returns all snapshots ordered by date, allowing you to track improvements over time.

Call `mcp__tabnine-ctx-cloud__get_ai_readiness_history` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Repository name to get AI readiness history for (e.g., "acme/web-app"). Supports partial matching. |
| dataSourceId | string | No | Data source ID to filter by (alternative to repository name) |
| limit | number | No | Maximum number of snapshots to return (default 10) |

## get_ai_readiness

Get the latest AI Readiness snapshot for a repository. Returns the overall score, grade, dimension scores, and recommendations. Run the ai-readiness-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_ai_readiness` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Repository name to get AI readiness for (e.g., "acme/web-app"). Supports partial matching. |
| dataSourceId | string | No | Data source ID to filter by (alternative to repository name) |
