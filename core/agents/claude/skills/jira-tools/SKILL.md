---
name: jira-tools
description: 'Manage Jira issues — get, create, transition, and comment on issues.'
allowed-tools: >-
  mcp__ctx-cloud__get_jira_issue, mcp__ctx-cloud__create_jira_issue,
  mcp__ctx-cloud__transition_jira_issue, mcp__ctx-cloud__add_jira_comment
---
# Jira Tools

Interact with Jira from the command line via the Context Engine MCP integration. Get, create, transition, and comment on issues.

## Get an Issue

Call `mcp__ctx-cloud__get_jira_issue` with issue_key=PAY-1234.

## Create an Issue

Call `mcp__ctx-cloud__create_jira_issue`.

## Transition an Issue

- **Move an issue to "In Progress"**: Call `mcp__ctx-cloud__transition_jira_issue` with issue_key=PAY-1234, transition="In Progress".
- **Close an issue**: Call `mcp__ctx-cloud__transition_jira_issue` with issue_key=PAY-1234, transition="Done".

## Add a Comment

Call `mcp__ctx-cloud__add_jira_comment`.

## When to Use

- To look up issue details without leaving the terminal.
- To create follow-up tickets during incident response or code review.
- To transition issues as part of an automated workflow.
