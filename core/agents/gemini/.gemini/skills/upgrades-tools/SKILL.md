---
name: upgrades-tools
description: >-
  Upgrades tools: get_major_upgrades, get_package_upgrade_history,
  get_upgrade_summary, get_upgrades_with_code_changes,
  get_upgrades_without_code_changes, list_upgrades
tags:
  - upgrades
  - auto-generated
group: upgrades
mcp-tools:
  - get_major_upgrades
  - get_package_upgrade_history
  - get_upgrade_summary
  - get_upgrades_with_code_changes
  - get_upgrades_without_code_changes
  - list_upgrades
---
# Upgrades Tools

> Auto-generated from 6 exported tool(s) in the Context Engine.

## get_major_upgrades

Get major version upgrades (e.g., 4.x to 5.x) that historically required code changes. These are the most impactful upgrades that often involve breaking changes and migrations. Run the upgrade-history-analyzer agent first to populate this data.
PREFER: Use 'dependency_check' for complete package assessment including major upgrade history, security status, and migration recommendations in one call.
USE THIS WHEN: You need to analyze major upgrades across multiple packages, or when researching upgrade patterns organization-wide.

Call `mcp__ctx-cloud__get_major_upgrades` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Filter by repository name (e.g., "owner/repo") |
| ecosystem | string | No | Filter by ecosystem (npm, maven, pypi, go, rust) |
| limit | number | No | Maximum number of upgrades to return (default 20) |

## get_package_upgrade_history

Get the upgrade history for a specific package. Shows all version changes over time, whether each upgrade required code changes, and who performed them. Run the upgrade-history-analyzer agent first to populate this data.
PREFER: Use 'dependency_check' for complete package assessment including security status, upgrade history, and migration recommendations in one call.
USE THIS WHEN: You need only the raw upgrade event history, or when analyzing upgrade patterns across multiple packages.

Call `mcp__ctx-cloud__get_package_upgrade_history` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | Package name to look up (e.g., "typescript", "lodash", "react") |
| repository | string | No | Filter by repository name (e.g., "owner/repo") |
| limit | number | No | Maximum number of upgrades to return (default 20) |

## get_upgrade_summary

Get a summary of upgrade analysis for a repository. Returns statistics about total upgrades, breakdown by category (with/without code changes), top upgraded packages, and upgrade sources (dependabot, renovate, manual). Run the upgrade-history-analyzer agent first to populate this data.

Call `mcp__ctx-cloud__get_upgrade_summary` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Repository name to get summary for (e.g., "owner/repo") |
| limit | number | No | Maximum number of snapshots to return (default 1, latest) |

## get_upgrades_with_code_changes

Get upgrade events that required code changes beyond the manifest file. These are upgrades that caused friction - requiring migrations, API updates, or breaking change fixes. Useful for identifying problematic dependencies. Run the upgrade-history-analyzer agent first to populate this data.

Call `mcp__ctx-cloud__get_upgrades_with_code_changes` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Filter by repository name (e.g., "owner/repo") |
| ecosystem | string | No | Filter by ecosystem (npm, maven, pypi, go, rust) |
| limit | number | No | Maximum number of upgrades to return (default 30) |

## get_upgrades_without_code_changes

Get upgrade events that were simple version bumps with no code changes. These are clean upgrades where only manifest/lock files changed. Useful for identifying dependencies that are safe to auto-merge. Run the upgrade-history-analyzer agent first to populate this data.

Call `mcp__ctx-cloud__get_upgrades_without_code_changes` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Filter by repository name (e.g., "owner/repo") |
| ecosystem | string | No | Filter by ecosystem (npm, maven, pypi, go, rust) |
| limit | number | No | Maximum number of upgrades to return (default 30) |

## list_upgrades

List all upgrade events discovered in a repository. Returns package name, versions, whether code changes were required, commit info, and upgrade source. Run the upgrade-history-analyzer agent first to populate this data.

Call `mcp__ctx-cloud__list_upgrades` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Filter by repository name (e.g., "owner/repo") |
| ecosystem | string | No | Filter by ecosystem (npm, maven, pypi, go, rust) |
| limit | number | No | Maximum number of upgrades to return (default 50) |
