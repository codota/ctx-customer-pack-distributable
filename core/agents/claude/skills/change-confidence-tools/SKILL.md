---
name: change-confidence-tools
description: 'Change confidence tools: get_change_confidence, get_file_risk_factors'
allowed-tools: >-
  mcp__tabnine-ctx-cloud__get_change_confidence,
  mcp__tabnine-ctx-cloud__get_file_risk_factors
---
# Change confidence Tools

> Auto-generated from 2 exported tool(s) in the Context Engine.

## get_change_confidence

Calculate a confidence score for a proposed code change.
Aggregates multiple risk signals into a single 0-100 score: - File risk metrics (churn, bug-fix ratio, hotspot status) - Blast radius (direct/transitive dependents, critical services) - Historical incidents (past issues in affected areas) - Code coupling (files that change together) - Expert coverage (knowledge concentration risk)
Score interpretation: - 90-100 (GREEN): Low risk, safe to merge - 75-89 (YELLOW): Moderate risk, review carefully - 50-74 (ORANGE): High risk, extensive testing needed - 0-49 (RED): Critical risk, escalation recommended
USE THIS BEFORE: Merging PRs, committing significant changes, deployments
Example: get_change_confidence(files=["src/payment/processor.ts", "src/payment/api.ts"])

Call `mcp__tabnine-ctx-cloud__get_change_confidence` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| files | array | Yes | List of file paths being changed (relative to repository root). Example: ["src/payment/processor.ts", "src/checkout/cart.ts"] |
| repository | string | No | Repository name for scoping queries. Optional but recommended for accuracy. |
| changeType | string | No | Type of change: "feature", "bugfix", "refactor", "dependency", "config". Affects scoring weights. Default: auto-detect from files. |

## get_file_risk_factors

Get detailed risk analysis for a single file.
Returns all risk signals contributing to the file's risk score: - Churn metrics (change frequency, commit count) - Bug-fix ratio (% of commits that are fixes) - Author analysis (expert count, knowledge concentration) - Historical incidents linked to this file/service - Coupling analysis (files that change together)
USE THIS WHEN: You want detailed breakdown for a specific file rather than an aggregate score for multiple files.

Call `mcp__tabnine-ctx-cloud__get_file_risk_factors` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| filepath | string | Yes | File path to analyze (relative to repository root). |
| repository | string | No | Repository name for scoping. Optional. |
