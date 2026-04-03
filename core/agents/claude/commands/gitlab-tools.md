Gitlab tools: add_gitlab_mr_comment, create_gitlab_merge_request, search_gitlab_issues

# Gitlab Tools

> Auto-generated from 3 exported tool(s) in the Context Engine.

## add_gitlab_mr_comment

Add a comment (note) to an existing GitLab merge request. Requires a connected and enabled GitLab data source.

```bash
ctx-cli mcp call add_gitlab_mr_comment -p projectId=<string> -p mergeRequestIid=<string> -p body=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| projectId | string | Yes | GitLab project ID (numeric) or URL-encoded path. |
| mergeRequestIid | string | Yes | The internal ID (IID) of the merge request within the project. |
| body | string | Yes | Comment body text. Supports GitLab Flavored Markdown. |

## create_gitlab_merge_request

Create a new merge request in a GitLab project. Requires a connected and enabled GitLab data source. Returns the created merge request details including IID and web URL.

```bash
ctx-cli mcp call create_gitlab_merge_request -p projectId=<string> -p sourceBranch=<string> -p targetBranch=<string> -p title=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| projectId | string | Yes | GitLab project ID (numeric) or URL-encoded path (e.g., "123" or "group%2Fproject"). |
| sourceBranch | string | Yes | The source branch name for the merge request. |
| targetBranch | string | Yes | The target branch name (e.g., "main", "develop"). |
| title | string | Yes | Title of the merge request. |
| description | string | No | Description body of the merge request. Supports GitLab Flavored Markdown. |

## search_gitlab_issues

Search GitLab issues in the knowledge graph. Supports filtering by service name, state, and free-text query against title/description. Use this to find open or closed GitLab issues related to a service or topic.
Prefer investigate_service when you need a full service overview — use this tool when you need a targeted GitLab issue search (e.g. all open issues for a service, issues matching a keyword).

```bash
ctx-cli mcp call search_gitlab_issues  -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | No | Free-text search against issue title and description (case-insensitive substring match). Leave empty to return all issues matching other filters. |
| serviceName | string | No | Filter to issues linked to a specific service (e.g. "order-service"). Matches against the service node name using a partial, case-insensitive match. |
| state | string | No | Filter by issue state: "opened" (default) or "closed". Pass "all" to return both. |