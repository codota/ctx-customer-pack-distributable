Development tools: create_feature_pr, get_feature, merge_feature_pr, start_new_feature, update_feature_decisions

# Development Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## create_feature_pr

Update a Feature entity with Pull Request information. Call this after creating a PR via gh CLI.

```bash
ctx-cli mcp call create_feature_pr -p featureName=<string> -p prNumber=<number> -p prUrl=<string> -p prTitle=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| featureName | string | Yes | The feature name to update |
| prNumber | number | Yes | The PR number |
| prUrl | string | Yes | The full PR URL |
| prTitle | string | Yes | The PR title |
| reviewers | string | No | Comma-separated list of reviewer usernames |
| filesChanged | string | No | Comma-separated list of changed files |

## get_feature

Retrieve information about a Feature entity by name.

```bash
ctx-cli mcp call get_feature -p featureName=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| featureName | string | Yes | The feature name to look up |

## merge_feature_pr

Mark a Feature as merged. Call this after successfully merging the PR.

```bash
ctx-cli mcp call merge_feature_pr -p featureName=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| featureName | string | Yes | The feature name to mark as merged |
| mergeCommit | string | No | The merge commit SHA |

## start_new_feature

Register a new development feature in the Context Engine. Creates a Feature entity to track the feature lifecycle including branch, worktree, decisions, and PR info. Call this after creating the git worktree and feature branch.

```bash
ctx-cli mcp call start_new_feature -p featureName=<string> -p branchName=<string> -p worktreePath=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| featureName | string | Yes | The feature name (used as entity name) |
| branchName | string | Yes | The full git branch name (e.g., feature/my-feature) |
| worktreePath | string | Yes | Relative path to the worktree (e.g., .worktrees/my-feature) |
| baseBranch | string | No | The base branch (default main) |
| description | string | No | Brief description of the feature |

## update_feature_decisions

Add a design decision to an existing Feature entity. Use this to record architectural choices, implementation decisions, and their rationale.

```bash
ctx-cli mcp call update_feature_decisions -p featureName=<string> -p decision=<string> -p rationale=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| featureName | string | Yes | The feature name to update |
| decision | string | Yes | The design decision that was made |
| rationale | string | Yes | The reasoning behind this decision |
| alternatives | string | No | Alternative approaches considered |