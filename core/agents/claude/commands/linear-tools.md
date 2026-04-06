Linear tools: add_linear_comment, create_linear_issue, list_linear_issues, list_linear_teams, transition_linear_issue, update_linear_issue

# Linear Tools

> Auto-generated from 6 exported tool(s) in the Context Engine.

## add_linear_comment

Add a comment to an existing Linear issue. Requires a connected and enabled Linear data source. The comment body supports markdown formatting.

Call `mcp__tabnine-ctx-cloud__add_linear_comment` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| issueId | string | Yes | The ID of the issue to comment on. This is the Linear internal UUID. |
| body | string | Yes | The comment body in markdown format. |

## create_linear_issue

Create a new Linear issue. Requires a connected and enabled Linear data source. Creates an issue with a title and team. Use update_linear_issue afterwards to set priority, assignee, labels, or other optional fields. Returns the created issue identifier and URL.

Call `mcp__tabnine-ctx-cloud__create_linear_issue` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| title | string | Yes | The title of the issue. |
| teamId | string | Yes | The ID of the team to create the issue in. Use list_linear_teams to find team IDs. |
| description | string | No | Markdown description of the issue. Defaults to empty if omitted. |

## list_linear_issues

List recent Linear issues ordered by last updated. Requires a connected and enabled Linear data source. Returns up to 50 issues across the workspace. Use this to find issue IDs before updating or commenting.

Call `mcp__tabnine-ctx-cloud__list_linear_issues` with parameters:

## list_linear_teams

List all teams in the Linear workspace. Requires a connected and enabled Linear data source. Returns team IDs, names, and keys. Useful for finding the teamId parameter needed by create_linear_issue.

Call `mcp__tabnine-ctx-cloud__list_linear_teams` with parameters:

## transition_linear_issue

Transition a Linear issue to a new workflow state (e.g., "In Progress", "Done"). Requires a connected and enabled Linear data source. Use list_linear_issues to find issue IDs and inspect current states.

Call `mcp__tabnine-ctx-cloud__transition_linear_issue` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| issueId | string | Yes | The ID of the issue to transition. This is the Linear internal UUID. |
| stateId | string | Yes | The ID of the target workflow state. Use the Linear UI or API to discover available state IDs for the issue's team. |

## update_linear_issue

Update the title and description of an existing Linear issue. Both fields are always set to the provided values — retrieve the current issue first (via list_linear_issues) to avoid overwriting fields you don't intend to change. Requires a connected and enabled Linear data source. To change status, use transition_linear_issue instead.

Call `mcp__tabnine-ctx-cloud__update_linear_issue` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| issueId | string | Yes | The ID of the issue to update. This is the Linear internal UUID, not the human-readable identifier like "ENG-123". Use list_linear_issues to find IDs. |
| title | string | Yes | The new title for the issue. |
| description | string | Yes | The new markdown description for the issue. Pass an empty string to clear. |