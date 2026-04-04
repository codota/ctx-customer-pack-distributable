---
name: onboard
description: >
  Walk through the complete 7-step Context Engine onboarding methodology.
  Validates setup, builds a testing lab, loads project data, measures baseline
  performance, enriches with domain context, and generates a rollout plan.
tags:
  - onboarding
  - methodology
group: onboarding
---
# Context Engine Onboarding

Walk through the complete 7-step onboarding methodology to evaluate and adopt the Context Engine.

## MANDATORY PREREQUISITE — Do This First

**DO NOT proceed to any step until `ctx-settings.yaml` exists and is valid.**

This file stores all credentials and configuration so that `ctx-loader` and `ctx-onboard` work without passing environment variables on every command.

Check if `ctx-settings.yaml` exists in the project root.

**If it exists**, read it and check:
- Are `CTX_API_URL` and `CTX_API_KEY` set? If not, ask for them.
- Are `GITHUB_ORG` and `GITHUB_REPO` set? If not, ask which repository to evaluate.
- Is `DATA_VOLUME` set? If not, ask the user which volume they want (ultra-light, light, standard, full) and add it to the file. Explain the options:
  - `ultra-light` — 1 day of history, push events only (fastest, for quick testing)
  - `light` — 7 days, push events only
  - `standard` — 30 days, pushes + PRs + issues (recommended)
  - `full` — 90 days, pushes + PRs + issues + releases (most comprehensive)

**If it doesn't exist**, walk the user through creating it:

1. **Context Engine connection** (required):
   - Ask for their Context Engine URL (e.g. `https://ctx.your-company.com`)
   - Ask for their CTX API key

2. **Project info**:
   - Ask for a project name
   - Ask which repository they want to evaluate (owner and repo name)

3. **Data volume** — ask how much data to load:
   - `ultra-light` — 1 day of history, push events only (fastest, for quick testing)
   - `light` — 7 days, push events only
   - `standard` — 30 days, pushes + PRs + issues (recommended)
   - `full` — 90 days, pushes + PRs + issues + releases (most comprehensive)

   Set `DATA_VOLUME` in the settings file. Default is `standard`.

4. **Source platform credentials** — ask which platforms they use and collect the relevant tokens:
   - **GitHub**: `GH_PAT` (Personal Access Token)
   - **GitLab**: `GITLAB_TOKEN` and `GITLAB_URL`
   - **Bitbucket**: `BITBUCKET_TOKEN` and `BITBUCKET_URL`
   - **Jira**: `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN`
   - **Confluence**: `CONFLUENCE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN`
   - **Slack**: `SLACK_BOT_TOKEN`
   - **PagerDuty**: `PAGERDUTY_API_KEY`
   - **Linear**: `LINEAR_API_KEY`

5. Create `ctx-settings.yaml` with the collected values:

```yaml
# Context Engine
CTX_API_URL: <their URL>
CTX_API_KEY: <their key>
PROJECT_NAME: <their project name>

# Repository (used by ctx-loader init to generate the manifest)
GITHUB_ORG: <org or owner>
GITHUB_REPO: <repo name>

# Data volume (ultra-light | light | standard | full)
DATA_VOLUME: standard

# Source platform credentials (only include what they use)
GH_PAT: <GitHub token>
JIRA_URL: <Jira URL>
JIRA_EMAIL: <Jira email>
JIRA_API_TOKEN: <Jira token>
# ... etc
```

Also check if `ctx-onboard` and `ctx-loader` are installed:
```bash
which ctx-onboard && which ctx-loader
```
If not found, tell the user to install them:
```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

## Checking Progress

Call `mcp__ctx-onboard__onboard_status` to see which steps are completed, in progress, or pending.

## The 7 Steps

Use MCP tools for all steps. Do NOT use Bash commands — use the `mcp__ctx-onboard__*` tools directly.

### Step 0: Initialize

Validate connectivity to the Context Engine and detect server capabilities.

Call `mcp__ctx-onboard__onboard_step_0`.

This checks:
- CTX API reachability and authentication
- Supported credential types and data source types
- Whether extension install is available (affects Step 5 mode)
- Available agent kinds

### Step 1: Build Testing Lab

Analyze your repository and generate a test plan with categorized test cases.

Call `mcp__ctx-onboard__onboard_step_1` with `repo_path` set to the repository path.

Produces `test-plan.yaml` with 5-10 test cases covering architecture, incident response, code intelligence, dependencies, and documentation.

### Step 2: Load Project Data

**Before starting:** Call `mcp__ctx-onboard__onboard_status` to check progress. If step 2 shows `in_progress` or `failed`, ask the user whether to retry or reset.

**Loading data:**

Create a `ctx-loader.yaml` manifest first if one doesn't exist:

Call `mcp__ctx-loader__loader_init` with `template: "minimal"`, `output: "ctx-loader.yaml"`. Set `owner` and `repo` if known.

Then start the load (runs in background, returns immediately):

Call `mcp__ctx-onboard__onboard_step_2_start` with `manifest: "ctx-loader.yaml"`.

Poll for completion (check every 15-30 seconds):

Call `mcp__ctx-onboard__onboard_step_2_status`.

The response will be one of:
- `{ "status": "loading" }` — still running, keep polling
- `{ "status": "completed" }` — done, move to step 3
- `{ "status": "failed", "loaderOutput": "..." }` — show the error to the user and offer to retry or reset

**Important:** Step 2 runs in the background because large repos can take minutes.

### Step 3: Baseline Without MCP

This step is agent-driven. You (the agent) answer the test questions yourself, then submit answers for scoring.

1. Get the test questions: call `mcp__ctx-onboard__onboard_step_3_get_questions`.

This returns the test cases. **Answer each question yourself WITHOUT using any Context Engine MCP tools.** Use only your training data.

2. Save your answers as a JSON file (e.g. `.ctx-onboarding/step3-answers.json`):
```json
[
  {"id": "tc-001", "category": "architecture", "question": "...", "answer": "your answer here"},
  {"id": "tc-002", "category": "incident-response", "question": "...", "answer": "your answer here"}
]
```

3. Submit for scoring: call `mcp__ctx-onboard__onboard_step_3_submit` with `responses_file: ".ctx-onboarding/step3-answers.json"`.

### Step 4: Baseline With MCP

Same as step 3, but this time **query the Context Engine** to answer.

1. Get the test questions: call `mcp__ctx-onboard__onboard_step_4_get_questions`.

2. Answer each question by querying the Context Engine using MCP tools:

- `mcp__ctx-cloud__search_knowledge` — semantic search
- `mcp__ctx-cloud__query_entities` — list/search entities by type
- `mcp__ctx-onboard__onboard_query_search` — search via onboard server
- `mcp__ctx-onboard__onboard_query_entities` — list entities via onboard server

Use the search results to build comprehensive answers. The key difference from step 3 is that you now have access to real project data from the knowledge graph.

3. Submit for scoring: call `mcp__ctx-onboard__onboard_step_4_submit` with `responses_file: ".ctx-onboarding/step4-answers.json"`.

The comparison shows the improvement from using Context Engine data.

### Step 5: Domain Enrichment (Optional)

Analyze your repository for domain-specific concepts and load them into the Context Engine.

Call `mcp__ctx-onboard__onboard_step_5` with `repo_path` set to the repository path.

This step is capability-gated:
- **Full mode**: Creates ontology extensions, coaching guidelines, and custom agents
- **Guideline-only mode**: If extension install is unavailable, converts domain concepts to coaching guidelines

### Step 6: Measure With Domain (Optional)

Re-run tests with domain enrichment active. Produces a 3-way comparison.

Call `mcp__ctx-onboard__onboard_step_6`.

### Step 7: Rollout Plan

Generate a phased adoption plan based on measured improvements.

Call `mcp__ctx-onboard__onboard_step_7`.

Produces a rollout plan with phases (pilot → early adopters → GA), risk assessment, and success criteria backed by the measured improvements.

## Execution Paths

- **Path A (Quick evaluation)**: Steps 0–4, then Step 7
- **Path B (Full evaluation)**: Steps 0–7 including domain enrichment
