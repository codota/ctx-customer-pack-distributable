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
mcp-tools: []
---
# Context Engine Onboarding

Walk through the complete 7-step onboarding methodology to evaluate and adopt the Context Engine.

## Before You Start

Check if `ctx-settings.yaml` exists in the project root.

**If it exists**, read it and check:
- Are `CTX_API_URL` and `CTX_API_KEY` set? If not, ask for them.
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
   - Ask which repository they want to evaluate

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

4. Create `ctx-settings.yaml` with the collected values:

```yaml
# Context Engine
CTX_API_URL: <their URL>
CTX_API_KEY: <their key>
PROJECT_NAME: <their project name>

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

## The 7 Steps

## Checking Progress

Use `ctx-onboard status` (without --json) for a readable summary:
```bash
ctx-onboard status
```
This shows each step's status. Do NOT pipe through python or jq — the plain output is already formatted.

## The 7 Steps

### Step 0: Initialize

Validate connectivity to the Context Engine and detect server capabilities.

```bash
ctx-onboard step-0 --json
```

This checks:
- CTX API reachability and authentication
- Supported credential types and data source types
- Whether extension install is available (affects Step 5 mode)
- Available agent kinds

### Step 1: Build Testing Lab

Analyze your repository and generate a test plan with categorized test cases.

```bash
ctx-onboard step-1 --repo-path /path/to/your/repo --json
```

Produces `test-plan.yaml` with 5-10 test cases covering architecture, incident response, code intelligence, dependencies, and documentation.

### Step 2: Load Project Data

**Before starting:** Check `ctx-onboard status` (no --json) to see the current progress. If step 2 shows `in_progress` or `failed`, ask the user:

> "Step 2 has a previous attempt that [failed/is stale]. Would you like to:
> 1. **Retry** — try loading again (the server will reuse the existing data source)
> 2. **Reset and retry** — clean up local state and start fresh"

If the user chooses reset:
```bash
rm -rf .ctx-loader .ctx-onboarding
```
Then re-run from step 0. The server-side data source will be reused automatically (lookup-then-create).

Do NOT use `ctx-loader rollback` for reset — it requires the manifest to be re-parsed which may fail if env vars aren't set.

**Loading data:**

Create a `ctx-loader.yaml` manifest first if one doesn't exist:
```bash
ctx-loader init --template minimal --output ctx-loader.yaml
```

Then start the load. This runs in the background — it returns immediately:
```bash
ctx-onboard step-2 --manifest ctx-loader.yaml --json
```

Poll for completion (check every 15-30 seconds):
```bash
ctx-onboard step-2 --status --json
```

The `--status` response will be one of:
- `{ "status": "loading", "pid": 1234 }` — still running, keep polling
- `{ "status": "completed" }` — done, move to step 3
- `{ "status": "failed", "loaderOutput": "..." }` — show the error to the user and offer to retry or reset

**Important:** Step 2 runs in the background because large repos can take minutes.
Do NOT wait for the initial `step-2` command to finish — it returns immediately.
Instead, poll with `--status` until it completes.

### Step 3: Baseline Without MCP

Run the test cases without Context Engine tools to establish a baseline.

```bash
ctx-onboard step-3 --json
```

Scores responses on 4 dimensions (relevance, depth, actionability, accuracy), each 0-5.

### Step 4: Baseline With MCP

Run the same test cases with Context Engine MCP tools enabled. Compare against Step 3.

```bash
ctx-onboard step-4 --json
```

Produces a comparison report quantifying the value of Context Engine integration.

### Step 5: Domain Enrichment (Optional)

Analyze your repository for domain-specific concepts and load them into the Context Engine.

```bash
ctx-onboard step-5 --repo-path /path/to/your/repo --json
```

This step is capability-gated:
- **Full mode**: Creates ontology extensions, coaching guidelines, and custom agents
- **Guideline-only mode**: If extension install is unavailable, converts domain concepts to coaching guidelines

### Step 6: Measure With Domain (Optional)

Re-run tests with domain enrichment active. Produces a 3-way comparison.

```bash
ctx-onboard step-6 --json
```

### Step 7: Rollout Plan

Generate a phased adoption plan based on measured improvements.

```bash
ctx-onboard step-7 --json
```

Produces a rollout plan with phases (pilot → early adopters → GA), risk assessment, and success criteria backed by the measured improvements.

## Execution Paths

- **Path A (Quick evaluation)**: Steps 0–4, then Step 7
- **Path B (Full evaluation)**: Steps 0–7 including domain enrichment

## Start Over

To reset all local state and start fresh:
```bash
rm -rf .ctx-loader .ctx-onboarding
```
