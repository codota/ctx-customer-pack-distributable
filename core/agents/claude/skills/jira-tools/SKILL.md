---
name: jira-tools
description: 'Manage Jira issues — get, create, transition, and comment on issues.'
allowed-tools: 'Bash(ctx-cli:*)'
---
# Jira Tools

Interact with Jira from the command line via the Context Engine MCP integration. Get, create, transition, and comment on issues.

## Get an Issue

```bash
ctx-cli mcp call get_jira_issue -p issue_key=PAY-1234 --raw
```

## Create an Issue

```bash
ctx-cli mcp call create_jira_issue \
  -p project_key=PAY \
  -p summary="Fix timeout in payment retry logic" \
  -p description="The retry loop does not respect the configured backoff interval." \
  -p issue_type=Bug \
  --raw
```

## Transition an Issue

```bash
# Move an issue to "In Progress"
ctx-cli mcp call transition_jira_issue -p issue_key=PAY-1234 -p transition="In Progress" --raw

# Close an issue
ctx-cli mcp call transition_jira_issue -p issue_key=PAY-1234 -p transition="Done" --raw
```

## Add a Comment

```bash
ctx-cli mcp call add_jira_comment \
  -p issue_key=PAY-1234 \
  -p comment="Root cause identified: missing null check in retry handler. Fix in PR #892." \
  --raw
```

## When to Use

- To look up issue details without leaving the terminal.
- To create follow-up tickets during incident response or code review.
- To transition issues as part of an automated workflow.
