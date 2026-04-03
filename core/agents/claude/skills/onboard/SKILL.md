---
name: onboard
description: >
  Walk through the complete 7-step Context Engine onboarding methodology.
  Validates setup, builds a testing lab, loads project data, measures baseline
  performance, enriches with domain context, and generates a rollout plan.
allowed-tools: 'Bash(ctx-cli:*)'
---
# Context Engine Onboarding

Walk through the complete 7-step onboarding methodology to evaluate and adopt the Context Engine.

## Prerequisites

- `ctx-onboard` CLI installed (run the installer with `--package all`)
- `CTX_API_URL` and `CTX_API_KEY` environment variables set
- A repository to evaluate

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

Load your project's data sources into the Context Engine.

```bash
ctx-onboard step-2 --manifest ctx-loader.yaml --json
```

Create a `ctx-loader.yaml` manifest first using:
```bash
ctx-loader init --template github-jira-slack --output ctx-loader.yaml
```

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

## Check Progress

```bash
ctx-onboard status --json
```

## Start Over

```bash
ctx-onboard reset --confirm
```
