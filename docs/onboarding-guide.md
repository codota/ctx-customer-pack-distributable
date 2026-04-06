# Onboarding Guide

The Context Engine onboarding is a structured 7-step evaluation methodology that measures the value the Context Engine adds to your AI coding workflow. It compares AI agent output with and without Context Engine tools, and optionally with domain-specific enrichment, producing a quantified comparison and a phased rollout plan.

This guide is for engineering leads, platform teams, and developer experience teams evaluating whether to adopt the Context Engine across their organization.

**What you will produce:**

- Quantified before/after comparison across 4 scoring dimensions
- Evidence of Context Engine impact on real questions about your codebase
- A phased rollout plan (pilot, early adopters, GA) backed by measured improvements

---

## Table of Contents

- [Prerequisites and Setup](#prerequisites-and-setup)
- [Choosing Your Evaluation Path](#choosing-your-evaluation-path)
- [Step-by-Step Guide](#step-by-step-guide)
  - [Step 0: Initialize](#step-0-initialize)
  - [Step 1: Build Testing Lab](#step-1-build-testing-lab)
  - [Step 2: Load Project Data](#step-2-load-project-data)
  - [Step 3: Baseline Without MCP](#step-3-baseline-without-mcp)
  - [Step 4: Baseline With MCP](#step-4-baseline-with-mcp)
  - [Step 5: Domain Enrichment](#step-5-domain-enrichment)
  - [Step 6: Measure With Domain](#step-6-measure-with-domain)
  - [Step 7: Rollout Plan](#step-7-rollout-plan)
- [Understanding Scoring](#understanding-scoring)
- [State and Progress](#state-and-progress)
- [Domain Enrichment Deep Dive](#domain-enrichment-deep-dive)
- [Rollout Planning](#rollout-planning)
- [Troubleshooting and FAQ](#troubleshooting-and-faq)

---

## Prerequisites and Setup

### What You Need

| Requirement | Description |
|-------------|-------------|
| Context Engine server | URL and API key from your organization |
| Repository to evaluate | A representative repository for your team's work |
| Data source credentials | Tokens for GitHub/GitLab, Jira/Linear, Slack, PagerDuty, etc. |
| AI coding agent | Claude Code recommended (Tier 1); Cursor, Gemini CLI, Tabnine also supported |

### Installing the Onboarding Package

Install everything (core skills + loader + onboarder):

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

Replace `claude` with `cursor`, `gemini`, or `tabnine` for other agents.

Verify the installation:

```bash
which tabnine-ctx-onboard && which tabnine-ctx-loader
```

Both commands should return paths. If not, check that the install directory is in your `PATH`.

### Configuration

You can configure onboarding via a `ctx-settings.yaml` file or environment variables. The YAML file is recommended because it keeps all settings in one place and is easier to share with your team.

#### Option A: ctx-settings.yaml (recommended)

Create `ctx-settings.yaml` in your project root:

```yaml
# Context Engine connection (required)
CTX_API_URL: https://ctx.your-company.com
CTX_API_KEY: ctx_your_key_here
PROJECT_NAME: my-project

# Source platform credentials (include only what you use)

# GitHub
GH_PAT: ghp_xxxxxxxxxxxx

# GitLab
GITLAB_TOKEN: glpat-xxxxxxxxxxxx
GITLAB_URL: https://gitlab.your-company.com

# Bitbucket
BITBUCKET_TOKEN: xxxxxxxxxxxx
BITBUCKET_URL: https://bitbucket.your-company.com

# Jira
JIRA_URL: https://your-company.atlassian.net
JIRA_EMAIL: you@company.com
JIRA_API_TOKEN: xxxxxxxxxxxx

# Confluence
CONFLUENCE_URL: https://your-company.atlassian.net/wiki
CONFLUENCE_EMAIL: you@company.com
CONFLUENCE_API_TOKEN: xxxxxxxxxxxx

# Slack
SLACK_BOT_TOKEN: xoxb-xxxxxxxxxxxx

# PagerDuty
PAGERDUTY_API_KEY: xxxxxxxxxxxx

# Linear
LINEAR_API_KEY: lin_api_xxxxxxxxxxxx
```

#### Option B: Environment variables

Export the same variables in your shell:

```bash
export CTX_API_URL=https://ctx.your-company.com
export CTX_API_KEY=ctx_your_key_here
export PROJECT_NAME=my-project
export GH_PAT=ghp_xxxxxxxxxxxx
# ... etc.
```

### Credential Requirements by Platform

| Platform | Required Credentials | Notes |
|----------|---------------------|-------|
| GitHub | `GH_PAT` | Personal Access Token with repo scope |
| GitLab | `GITLAB_TOKEN`, `GITLAB_URL` | PAT with read_api scope |
| Bitbucket | `BITBUCKET_TOKEN`, `BITBUCKET_URL` | App password with repo read |
| Jira | `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` | API token from id.atlassian.com |
| Confluence | `CONFLUENCE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN` | Same Atlassian API token works |
| Slack | `SLACK_BOT_TOKEN` | Bot token with channels:history scope |
| PagerDuty | `PAGERDUTY_API_KEY` | Read-only API key |
| Linear | `LINEAR_API_KEY` | Personal API key |

Only include credentials for platforms your team actually uses. At minimum, you need CTX connection details and one source code platform (GitHub, GitLab, or Bitbucket).

---

## Choosing Your Evaluation Path

There are two evaluation paths. Choose based on how thorough an evaluation you need.

### Path A: Quick Evaluation

**Steps:** 0 &rarr; 1 &rarr; 2 &rarr; 3 &rarr; 4 &rarr; 7

Measures the baseline improvement from Context Engine tools without domain enrichment. Best for teams that want a fast go/no-go decision.

### Path B: Full Evaluation

**Steps:** 0 &rarr; 1 &rarr; 2 &rarr; 3 &rarr; 4 &rarr; 5 &rarr; 6 &rarr; 7

Adds domain enrichment (Step 5) and a 3-way comparison (Step 6). Best for teams that want to understand the full potential, including domain-specific customization.

### Step Dependency Diagram

```
Step 0: Initialize
  |
  +-- Step 1: Build Testing Lab
  |     |
  |     +-- Step 3: Baseline (no MCP)
  |           |
  +-- Step 2: Load Project Data
        |
        +-- Step 4: Baseline (with MCP)  [requires Steps 2 + 3]
              |
              +-- Step 7: Rollout Plan  [Path A ends here]
              |
              +-- Step 5: Domain Enrichment
                    |
                    +-- Step 6: Measure With Domain
                          |
                          +-- Step 7: Rollout Plan  [Path B ends here]
```

### How to Choose

Choose **Path A** if:
- You want quick results to justify further investment
- Your codebase does not have strong domain-specific conventions
- You are evaluating multiple tools and need a fast comparison

Choose **Path B** if:
- Your codebase has domain-specific terminology, internal frameworks, or conventions that a generic AI agent would not know
- You want the most complete picture of Context Engine value
- You are building a detailed adoption proposal for leadership

---

## Step-by-Step Guide

### Step 0: Initialize

**Purpose:** Validate connectivity to the Context Engine and detect server capabilities.

```bash
tabnine-ctx-onboard step-0 --json
```

Reads `CTX_API_URL` and `CTX_API_KEY` from `ctx-settings.yaml` or environment variables.

**What it checks:**

- CTX API reachability and authentication
- Supported credential types and data source types
- Whether extension install is available (determines Step 5 mode)
- Available agent kinds

**What "capabilities" mean:**

The init step probes your Context Engine server to detect what features are available. The most important capability is **extension install**:

- **Available:** Step 5 will run in full mode, creating ontology extensions, coaching guidelines, and custom agents.
- **Not available:** Step 5 will fall back to guideline-only mode, converting domain concepts to coaching guidelines.

This is not an error -- guideline-only mode still provides meaningful domain enrichment.

**If this step fails:**

- "Connection refused" or timeout: check that `CTX_API_URL` is correct and reachable.
- "401 Unauthorized": check that `CTX_API_KEY` is valid and not expired.
- Network errors: check proxy (`HTTPS_PROXY`) and CA cert (`NODE_EXTRA_CA_CERTS`) settings.

### Step 1: Build Testing Lab

**Purpose:** Analyze your repository and generate a test plan with categorized test cases.

```bash
tabnine-ctx-onboard step-1 --repo-path /path/to/your/repo --json
```

**What it produces:**

A `test-plan.yaml` file stored in `.tabnine-ctx-onboarding/` with 5-10 test cases. Test cases are generated by analyzing your repository's structure, dependencies, README, and configuration files.

**Test case categories:**

| Category | Example Question |
|----------|-----------------|
| Architecture | "What are the main services in this system and how do they communicate?" |
| Incident response | "If the checkout service goes down, what is the blast radius?" |
| Code intelligence | "Who are the experts on the payment processing module?" |
| Dependencies | "What are the most critical third-party dependencies?" |
| Documentation | "Where is the deployment process documented?" |

**Reviewing the test plan:**

After generation, review `.tabnine-ctx-onboarding/test-plan.yaml`. You can modify test cases to better reflect the questions your team actually asks. The more representative the questions, the more meaningful the evaluation.

**Tips:**

- Point `--repo-path` at a representative repository -- one that reflects the kind of work your team does daily.
- A repo with multiple services, dependencies, and some history produces better test cases.

### Step 2: Load Project Data

**Purpose:** Load your project's data sources into the Context Engine knowledge graph.

This step populates the knowledge graph so that Context Engine tools have data to query. Without this step, tools return empty results.

**Step 2a: Create a loader manifest.**

```bash
tabnine-ctx-loader init --template github-jira-slack --output tabnine-ctx-loader.yaml
```

Choose a template based on your tool stack:

| Template | When to Use |
|----------|-------------|
| `minimal` | GitHub only, simplest starting point |
| `github-jira-slack` | GitHub + Jira + Slack |
| `gitlab-linear-pagerduty` | GitLab + Linear + PagerDuty |

**Step 2b: Fill in the manifest.**

Edit `tabnine-ctx-loader.yaml` to replace placeholder values. Variables like `${GH_PAT}` are substituted from your environment or `ctx-settings.yaml`. Verify all credential references match your configuration.

**Step 2c: Validate the manifest.**

```bash
tabnine-ctx-loader validate --manifest tabnine-ctx-loader.yaml --json
```

Fix any validation errors before proceeding.

**Step 2d: Load the data.**

```bash
tabnine-ctx-onboard step-2 --manifest tabnine-ctx-loader.yaml --json
```

This may take several minutes depending on the size of your data sources.

**Step 2e: Verify the load.**

```bash
tabnine-ctx-loader status --json
```

Confirm that all data sources show a successful sync status.

**Common issues:**

- **Authentication failures:** Double-check credential values. Ensure tokens have the required scopes.
- **Rate limiting:** The loader respects rate limits. If loading is slow, this is normal for large data sources.
- **Partial load:** If some sources fail, you can re-run the load. Successfully loaded sources are skipped.

### Step 3: Baseline Without MCP

**Purpose:** Run the test cases without Context Engine tools to establish a baseline.

```bash
tabnine-ctx-onboard step-3 --json
```

**What happens:**

Your AI agent answers each test case using only its built-in knowledge and local context (files in the repository). No MCP tools are called. This establishes what the agent can do without the Context Engine.

**Scoring:**

Each response is scored on 4 dimensions (see [Understanding Scoring](#understanding-scoring)):

| Dimension | What it Measures |
|-----------|-----------------|
| Relevance | Does the answer address the specific question? |
| Depth | Does the answer go beyond surface-level information? |
| Actionability | Can you act on the answer without further research? |
| Accuracy | Is the information factually correct? |

Each dimension is scored 0-5. Total score per test case: 0-20.

**What to expect:**

For organization-specific questions (service architecture, team ownership, incident history), scores are typically in the 1-3 range. The agent can reason about code structure but lacks organizational context.

### Step 4: Baseline With MCP

**Purpose:** Run the same test cases with Context Engine MCP tools enabled and compare against Step 3.

```bash
tabnine-ctx-onboard step-4 --json
```

**What happens:**

The AI agent answers the same test cases, but now it can use Context Engine tools (`investigate_service`, `search_knowledge`, `blast_radius`, etc.) to access the knowledge graph.

**Output:**

A comparison report showing Step 3 vs. Step 4 scores:

- Per-test-case scores on each dimension
- Average improvement per dimension
- Overall improvement percentage
- Tool usage metrics (which tools were called, how many times)

**What to expect:**

Significant improvement in:
- **Depth** -- answers include specific service names, dependencies, team contacts
- **Accuracy** -- answers reference real data rather than general knowledge
- **Actionability** -- answers include concrete next steps, runbook links, escalation paths

**If doing Path A:** After reviewing the comparison, skip to [Step 7](#step-7-rollout-plan).

### Step 5: Domain Enrichment

**Purpose:** Analyze your repository for domain-specific concepts and load them into the Context Engine.

```bash
tabnine-ctx-onboard step-5 --repo-path /path/to/your/repo --json
```

Use `--dry-run` to see what would be generated without loading anything:

```bash
tabnine-ctx-onboard step-5 --repo-path /path/to/your/repo --dry-run --json
```

**What it does:**

1. **Analyzes** your repository: scans code patterns, naming conventions, domain terminology, internal frameworks, and architectural patterns.
2. **Builds** a domain model: generates entity types, relationship types, coaching guidelines, and optionally custom agent definitions.
3. **Loads** the model into the Context Engine via the REST API.

**Capability gating:**

This step adapts based on capabilities detected in Step 0:

| Mode | When | What Gets Created |
|------|------|-------------------|
| Full mode | Extension install available | Ontology extensions + coaching guidelines + custom agents |
| Guideline-only mode | Extension install unavailable | Coaching guidelines only (domain concepts converted to guidelines) |

Guideline-only mode is a graceful fallback, not an error. It still provides meaningful domain enrichment.

**Output:**

A domain model stored in `.tabnine-ctx-onboarding/domain-model.yaml` containing the generated entities, relationships, and guidelines.

See [Domain Enrichment Deep Dive](#domain-enrichment-deep-dive) for more detail.

### Step 6: Measure With Domain

**Purpose:** Re-run the test cases with domain enrichment active and produce a 3-way comparison.

```bash
tabnine-ctx-onboard step-6 --json
```

**Output:**

A 3-way comparison report:

| Column | Source |
|--------|--------|
| No MCP | Step 3 scores |
| With MCP | Step 4 scores |
| With Domain | Step 6 scores |

**Scoring note:** Only answer-quality metrics (relevance, depth, actionability, accuracy) are compared across all three modes. Tool usage metrics are only compared between the two MCP-enabled modes (Steps 4 and 6).

**What to look for:**

- Additional improvement from domain enrichment, particularly in relevance and accuracy
- Whether the agent uses domain-specific terminology correctly
- Whether answers reference domain concepts that only exist in your codebase

### Step 7: Rollout Plan

**Purpose:** Generate a phased adoption plan based on measured improvements.

```bash
tabnine-ctx-onboard step-7 --json
```

**Output:**

A rollout plan document with:

- **Phases:** Pilot (small team) &rarr; Early Adopters (3-5 teams) &rarr; General Availability
- **Risk assessment:** Identified risks and mitigations for each phase
- **Success criteria:** Measurable targets backed by the improvements from previous steps
- **Timeline:** Suggested duration for each phase

The plan uses your actual measurement data to justify each recommendation. See [Rollout Planning](#rollout-planning) for more detail.

---

## Understanding Scoring

### The Four Dimensions

Each AI agent response is scored on four dimensions, each on a 0-5 scale:

| Dimension | What it Measures | Example of High Score |
|-----------|------------------|-----------------------|
| **Relevance** | Does the answer address the specific question asked? | Directly answers the question with on-topic information |
| **Depth** | Does the answer go beyond surface-level information? | Includes specific details, multiple layers of analysis |
| **Actionability** | Can you act on the answer without further research? | Provides concrete steps, commands, or links |
| **Accuracy** | Is the information factually correct? | Service names, dependencies, and contacts are all correct |

### Score Levels

| Score | Level | Description |
|-------|-------|-------------|
| 0 | None | No useful information provided |
| 1 | Minimal | Touches on the topic but largely unhelpful |
| 2 | Partial | Some relevant information but significant gaps |
| 3 | Adequate | Addresses the question with reasonable detail |
| 4 | Good | Thorough answer with specific, actionable details |
| 5 | Excellent | Complete, accurate, and immediately actionable |

### Reading the Comparison Report

The comparison report shows:

- **Per-test-case breakdown:** Scores for each test case across each mode (no MCP, with MCP, with domain).
- **Dimension averages:** Average score per dimension across all test cases.
- **Delta values:** The improvement from one mode to the next. A positive delta means improvement.
- **Overall improvement:** Percentage improvement in total score.

Focus on:

1. **Which dimensions improved most** -- this tells you where the Context Engine adds the most value.
2. **Which test categories improved most** -- this tells you which workflows benefit most.
3. **Absolute scores vs. deltas** -- a jump from 1 to 3 (delta +2) is more significant than 3 to 4 (delta +1), even though the latter has a higher final score.

### Tool Usage Metrics

Available only for MCP-enabled runs (Steps 4 and 6):

- **Tools called:** Which Context Engine tools the agent invoked.
- **Call count:** How many tool calls per test case.
- **Entities referenced:** How many knowledge graph entities were used in answers.

Step 3 (no MCP) is never scored on tool usage -- this is by design to ensure fair comparison.

---

## State and Progress

### The .tabnine-ctx-onboarding Directory

All onboarding state is persisted in `.tabnine-ctx-onboarding/` in your project root:

| File | Contents |
|------|----------|
| `state.json` | Step statuses, timestamps, and results |
| `test-plan.yaml` | Generated test cases (after Step 1) |
| `domain-model.yaml` | Generated domain model (after Step 5) |

### Checking Progress

```bash
tabnine-ctx-onboard status --json
```

Shows the status of each step: `pending`, `in_progress`, `completed`, `failed`, or `skipped`.

### Resuming After Interruption

State is checkpointed atomically after each step completes. If the process is interrupted, you can resume from where you left off by re-running the command for the current step. Completed steps are not re-run.

### Starting Over

```bash
tabnine-ctx-onboard reset --confirm
```

Clears all onboarding state and allows you to begin fresh. Use `--confirm` to skip the confirmation prompt.

### Sharing Results

The `.tabnine-ctx-onboarding/` directory contains all results. You can commit it to your repository or copy it to share with stakeholders. The comparison reports in `state.json` include all scoring data needed for a rollout decision.

---

## Domain Enrichment Deep Dive

### What Domain Enrichment Does

Domain enrichment (Step 5) analyzes your repository to extract knowledge that is specific to your codebase and organization. This includes:

- **Terminology:** Domain-specific terms and their meanings (e.g., "saga" refers to your distributed transaction pattern, not the general concept).
- **Patterns:** Recurring code patterns and conventions in your codebase.
- **Architecture:** How your specific services are structured and interact.
- **Rules:** Coding conventions and standards unique to your team.

This knowledge is loaded into the Context Engine so that AI agents give answers grounded in your specific domain.

### Full Mode vs. Guideline-Only Mode

| Aspect | Full Mode | Guideline-Only Mode |
|--------|-----------|---------------------|
| **When** | Extension install available | Extension install unavailable |
| **Ontology extensions** | Creates new entity types in the knowledge graph | Not created |
| **Coaching guidelines** | Created from domain analysis | Created (domain concepts converted to guidelines) |
| **Custom agents** | Created for domain-specific tasks | Not created |
| **Value** | Full domain integration | Domain context via guidelines |

Both modes provide meaningful enrichment. Guideline-only mode is a graceful fallback that still teaches the AI agent about your domain conventions.

### How Capability Gating Works

During Step 0, the onboarder probes your Context Engine server to detect whether it supports extension installation. This is a server-side feature that may not be available on all deployments.

The capability detection happens once and is stored in the onboarding state. Step 5 reads this state and automatically selects the appropriate mode.

### What Gets Generated

**In full mode:**

1. **Entity types:** New node types in the knowledge graph representing domain concepts specific to your codebase (e.g., a `PaymentSaga` entity type if your system uses a saga pattern).
2. **Relationship types:** New edge types representing domain-specific connections.
3. **Coaching guidelines:** Rules and standards extracted from your code patterns, registered as guidelines the AI agent follows.
4. **Custom agents:** Agent definitions tailored to domain-specific tasks.

**In guideline-only mode:**

1. **Coaching guidelines:** Domain concepts are converted to textual guidelines that inform the AI agent about your conventions, terminology, and patterns.

### When to Use Path B

Use the full evaluation (Path B) when:

- Your codebase uses internal frameworks, custom abstractions, or domain-specific patterns that generic AI models would not know about.
- Your team has strong coding conventions that are not documented in standard ways.
- You want to demonstrate the maximum possible value of the Context Engine.
- You are building a detailed case for organization-wide adoption.

If your codebase follows standard patterns and uses well-known frameworks, Path A may be sufficient to demonstrate value.

---

## Rollout Planning

### Phases

The rollout plan generated in Step 7 follows a three-phase approach:

**Phase 1: Pilot**

- Scope: 1 team, 1-2 repositories
- Duration: 1-2 weeks
- Goal: Validate the integration works in your environment and gather initial feedback.
- Success criteria: Derived from your measurement data (e.g., "average depth score improves by X points").

**Phase 2: Early Adopters**

- Scope: 3-5 teams
- Duration: 2-4 weeks
- Goal: Validate across different team workflows and codebases. Identify any team-specific configuration needs.
- Success criteria: Consistent improvement across teams, positive developer feedback.

**Phase 3: General Availability**

- Scope: Organization-wide
- Duration: Ongoing
- Goal: Full adoption with monitoring and continuous improvement.
- Success criteria: Adoption rate targets, sustained improvement in developer productivity metrics.

### Success Criteria

Each phase has success criteria linked to your measurement data:

- Score improvements from Steps 3-4 (or 3-6) set the expected baseline for improvement.
- The plan converts raw scores into practical targets (e.g., "developers report finding relevant context in under 30 seconds for 80% of service investigations").
- Criteria are tiered: must-have criteria for phase promotion and nice-to-have criteria for optimization.

### Risk Assessment

The rollout plan identifies common risks:

- **Data freshness:** Knowledge graph data can become stale. The plan includes sync schedule recommendations.
- **Adoption friction:** Developer onboarding and habit change. The plan includes training and documentation recommendations.
- **Coverage gaps:** Some repositories or services may not be loaded. The plan includes data source expansion recommendations.
- **Performance:** Tool response times under load. The plan includes monitoring recommendations.

### Customizing the Plan

The generated plan is a starting point. Customize it for your organization:

- Adjust phase durations based on your release cadence and team availability.
- Add or modify success criteria to match your existing developer productivity metrics.
- Include your organization's change management process requirements.
- Add budget and resource requirements specific to your deployment.

---

## Troubleshooting and FAQ

### Troubleshooting by Step

**Step 0: Initialize**

| Problem | Solution |
|---------|----------|
| Connection refused | Verify `CTX_API_URL` is correct. Test with `curl -s $CTX_API_URL/health` |
| 401 Unauthorized | Verify `CTX_API_KEY` is valid and not expired |
| Timeout | Check proxy settings (`HTTPS_PROXY`) and CA certificates (`NODE_EXTRA_CA_CERTS`) |

**Step 1: Build Testing Lab**

| Problem | Solution |
|---------|----------|
| "Invalid repo path" | Ensure `--repo-path` points to a directory containing source code |
| Few test cases generated | Larger repos with more structure produce better tests. Consider using a more representative repo |

**Step 2: Load Project Data**

| Problem | Solution |
|---------|----------|
| Credential errors | Verify tokens have correct scopes. See [Credential Requirements](#credential-requirements-by-platform) |
| Rate limiting | Normal for large data sources. The loader will retry automatically |
| Partial load | Re-run Step 2. Successfully loaded sources are skipped |
| Manifest validation errors | Run `tabnine-ctx-loader validate --manifest tabnine-ctx-loader.yaml --json` to see specific errors |

**Steps 3-4: Scoring**

| Problem | Solution |
|---------|----------|
| Unexpectedly low scores | Verify data was loaded (Step 2) by running `tabnine-ctx-loader status --json` |
| Tools not being called (Step 4) | Verify MCP tools are accessible: `tabnine-ctx-cli mcp list` |

**Step 5: Domain Enrichment**

| Problem | Solution |
|---------|----------|
| Guideline-only mode | Not an error. The server does not support extension install. Guideline-only mode still provides value |
| Timeout on large repos | The analyzer caps at 10,000 files. For very large monorepos, point at a representative subdirectory |

**Step 7: Rollout Plan**

| Problem | Solution |
|---------|----------|
| "Prerequisites not met" | Step 7 requires Step 4 (Path A) or Step 6 (Path B) to be completed first |

### FAQ

**Can I run individual steps out of order?**

No. Steps have prerequisites and must be run in sequence. The state manager validates prerequisites before each step.

**Can I re-run a step?**

Yes. Re-running a step overwrites its previous result. This is useful if you've improved your data or want to adjust test cases.

**Where are results stored?**

In `.tabnine-ctx-onboarding/` in the project root. This directory contains `state.json` (all step results), `test-plan.yaml`, and `domain-model.yaml`.

**Can I evaluate multiple repositories?**

Yes. Run the onboarding process separately for each repository. Each gets its own `.tabnine-ctx-onboarding/` directory. Point `--repo-path` at a different repo for each evaluation.

**What AI agents are supported for onboarding?**

Any supported agent (Claude Code, Cursor, Gemini CLI, Tabnine). Claude Code is recommended for the best experience as a Tier 1 agent.

**Can I customize the test cases?**

Yes. After Step 1 generates the test plan, edit `.tabnine-ctx-onboarding/test-plan.yaml` before proceeding to Step 3. Add, remove, or modify test cases to better reflect your team's real questions.

**What if my Context Engine server has limited data?**

The evaluation is most meaningful when the knowledge graph has representative data loaded. If only a few data sources are connected, the improvement from Steps 3 to 4 may be smaller. Load more data sources in Step 2 for a more representative evaluation.

**How do I share results with leadership?**

The `.tabnine-ctx-onboarding/state.json` file contains all measurement data. Step 7 generates a formatted rollout plan document. You can commit these to your repository or export them for a presentation.

---

*For detailed information about Context Engine tools and workflows, see the [Context Engine User Guide](context-engine-guide.md).*
