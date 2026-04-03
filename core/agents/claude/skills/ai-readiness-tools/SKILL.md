---
name: ai-readiness-tools
description: 'Ai readiness tools: get_ai_readiness_history, get_ai_readiness'
allowed-tools: 'Bash(ctx-cli:*)'
---
# Ai readiness Tools

> Auto-generated from 2 exported tool(s) in the Context Engine.

## get_ai_readiness_history

Get the historical AI Readiness snapshots for a repository. Returns all snapshots ordered by date, allowing you to track improvements over time.

```bash
ctx-cli mcp call get_ai_readiness_history  -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Repository name to get AI readiness history for (e.g., "acme/web-app"). Supports partial matching. |
| dataSourceId | string | No | Data source ID to filter by (alternative to repository name) |
| limit | number | No | Maximum number of snapshots to return (default 10) |

## get_ai_readiness

Get the latest AI Readiness snapshot for a repository. Returns the overall score, grade, dimension scores, and recommendations. Run the ai-readiness-analyzer agent first to populate this data.

```bash
ctx-cli mcp call get_ai_readiness  -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Repository name to get AI readiness for (e.g., "acme/web-app"). Supports partial matching. |
| dataSourceId | string | No | Data source ID to filter by (alternative to repository name) |
