Git insights tools: get_author_expertise, get_codebase_hotspots, get_coupling_issues, get_file_experts, get_file_risk, get_git_insights_summary, get_module_boundaries, get_recent_activity, get_related_files

# Git insights Tools

> Auto-generated from 9 exported tool(s) in the Context Engine.

## get_author_expertise

Get the expertise areas for a specific author or list all experts in the codebase. Shows which parts of the codebase each author knows best based on their commit history. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_author_expertise` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| author | string | No | Author name to look up (leave empty to get all experts) |
| repository | string | No | Optional repository name to filter by |
| limit | number | No | Maximum number of results to return (default 20) |

## get_codebase_hotspots

Get the hotspots in the codebase - files that change most frequently. Hotspots often indicate areas of high activity, potential complexity, or code that may need refactoring. Includes churn score, commit count, and risk assessment. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_codebase_hotspots` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Optional repository name to filter by |
| limit | number | No | Maximum number of hotspots to return (default 20) |

## get_coupling_issues

Get coupling issues between files or modules in the codebase. Identifies files that frequently change together but belong to different modules, which may indicate hidden dependencies or architectural issues. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_coupling_issues` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Optional repository name to filter by |
| limit | number | No | Maximum number of coupling issues to return (default 20) |

## get_file_experts

Get the experts (most knowledgeable contributors) for a specific file based on git history analysis. Returns authors ranked by their expertise score, which considers commit count, lines authored, and recency of contributions. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_file_experts` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| filePath | string | Yes | The file path to find experts for (e.g., "src/core/engine.ts") |
| repository | string | No | Optional repository name to filter by |
| limit | number | No | Maximum number of experts to return (default 5) |

## get_file_risk

Get the risk assessment for a specific file based on git history analysis. Risk score considers churn rate, bug fix ratio, number of authors, and recency. Returns risk score (0-1) and a recommendation (low/medium/high/critical). Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_file_risk` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| filePath | string | Yes | The file path to assess risk for |
| repository | string | No | Optional repository name to filter by |

## get_git_insights_summary

Get a summary of the git insights analysis for a repository. Includes overall statistics like total commits analyzed, number of files, authors, top hotspots, and health score. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_git_insights_summary` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Repository name to get summary for (optional) |

## get_module_boundaries

Get the logical module boundaries in the codebase based on co-change patterns. Identifies which directories form cohesive modules and where there might be coupling issues between modules. Useful for understanding the actual (not just intended) architecture. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_module_boundaries` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Optional repository name to filter by |
| limit | number | No | Maximum number of modules to return (default 20) |

## get_recent_activity

Get recent activity in the codebase including recently modified files and active directories. Useful for understanding what's currently being worked on and where development effort is focused. Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_recent_activity` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| repository | string | No | Optional repository name to filter by |
| path | string | No | Optional path prefix to filter activity (e.g., "src/api") |
| limit | number | No | Maximum number of results to return (default 20) |

## get_related_files

Get files that frequently change together with the specified file based on git history co-change analysis. Useful for understanding ripple effects - "if I change X, what else might need to change?" Run the git-insights-analyzer agent first to populate this data.

Call `mcp__tabnine-ctx-cloud__get_related_files` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| filePath | string | Yes | The file path to find related files for |
| repository | string | No | Optional repository name to filter by |
| limit | number | No | Maximum number of related files to return (default 10) |