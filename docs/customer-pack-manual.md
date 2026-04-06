# Context Engine Customer Pack Manual

This manual is the detailed customer reference for the Context Engine Customer Pack. It covers:

- installation and setup
- `ctx-settings.yaml`
- `ctx-skills` for common engineering tasks
- `tabnine-ctx-loader` command and manifest reference
- `tabnine-ctx-onboard` step-by-step reference

It is written for customers and intentionally avoids implementation internals.

---

## 1. Product Overview

The Customer Pack has three customer-facing parts:

| Component | What it does | Typical user |
|-----------|--------------|--------------|
| `ctx-skills` | Gives your AI coding agent context-aware workflows | Engineers and reviewers |
| `tabnine-ctx-loader` | Loads and refreshes engineering context in Context Engine | Platform, developer experience, and setup owners |
| `tabnine-ctx-onboard` | Runs a structured evaluation and adoption workflow | Engineering leads and pilot owners |

### When to use each component

| If you want to... | Use |
|-------------------|-----|
| investigate a service, review a PR, or find prior art | `ctx-skills` |
| load repos, issues, docs, chat, or on-call data | `tabnine-ctx-loader` |
| prove value and create a rollout plan | `tabnine-ctx-onboard` |

---

## 2. Installation

### Package options

| Install target | Includes |
|----------------|----------|
| `core` | `ctx-skills`, hooks, and Context Engine connectivity for your agent |
| `loader` | `core` plus `tabnine-ctx-loader` |
| `all` | `core`, `tabnine-ctx-loader`, and `tabnine-ctx-onboard` |

### Recommended install

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

Replace `claude` with `cursor`, `gemini`, or `tabnine` as needed.

### Supported agent targets

| Agent | Notes |
|-------|-------|
| Claude Code | Full first-class experience |
| Cursor | Installed skills and rules |
| Gemini CLI | Installed skills |
| Tabnine | Installed skills |
| GitHub Copilot | Preview support |
| Codex | Preview support |

### Verify installation

```bash
which tabnine-ctx-loader
which tabnine-ctx-onboard
```

If you installed `core` only, verify the pack from your agent instead by asking a Context Engine question.

---

## 3. Configuration

### `ctx-settings.yaml`

Create `ctx-settings.yaml` in the working directory where you will run the tools.

Example:

```yaml
CTX_API_URL: https://ctx.your-company.com
CTX_API_KEY: ctx_your_key_here
PROJECT_NAME: acme-store

GITHUB_ORG: acme
GITHUB_REPO: storefront
DATA_VOLUME: standard

GH_PAT: ghp_xxxxxxxxxxxx

JIRA_URL: https://acme.atlassian.net
JIRA_EMAIL: you@acme.com
JIRA_API_TOKEN: xxxxxxxxxxxx

SLACK_BOT_TOKEN: xoxb-xxxxxxxxxxxx
```

All three tools read this file automatically. You do not need to re-type these values for each command.

### Required keys

| Key | Required | Purpose |
|-----|----------|---------|
| `CTX_API_URL` | Yes | Context Engine server URL |
| `CTX_API_KEY` | Yes | API key for Context Engine |
| `PROJECT_NAME` | Recommended | Friendly project name used across workflows |

### Common repository keys

| Key | When you need it |
|-----|------------------|
| `GITHUB_ORG` | GitHub-based templates and onboarding |
| `GITHUB_REPO` | GitHub-based templates and onboarding |
| `GITLAB_URL` | GitLab sources |
| `GITLAB_TOKEN` | GitLab sources |

### Data volume presets

`DATA_VOLUME` controls how much recent history is used by onboarding-driven loading defaults.

| Preset | Typical use | History | Typical event scope |
|--------|-------------|---------|---------------------|
| `ultra-light` | Fast smoke test | 1 day | pushes |
| `light` | Quick evaluation | 7 days | pushes |
| `standard` | Recommended default | 30 days | pushes, PRs, issues |
| `full` | Richest evaluation | 90 days | pushes, PRs, issues, releases |

### Credential reference

Only include credentials for systems you use.

| Platform | Keys |
|----------|------|
| GitHub | `GH_PAT` |
| GitLab | `GITLAB_URL`, `GITLAB_TOKEN` |
| Bitbucket | `BITBUCKET_URL`, `BITBUCKET_TOKEN` |
| Jira | `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` |
| Confluence | `CONFLUENCE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN` |
| Slack | `SLACK_BOT_TOKEN` |
| PagerDuty | `PAGERDUTY_API_KEY` |
| Linear | `LINEAR_API_KEY` |

### Environment variables

Environment variables are supported, but `ctx-settings.yaml` is usually easier to share and maintain for customer teams.

---

## 4. `ctx-skills` Reference

`ctx-skills` are the everyday front door to the Customer Pack. In supported agents, they are available as installed skills, commands, or both.

### How to use them

Two good patterns:

1. Ask in plain English.
2. If your agent supports slash commands, use the matching command name.

Examples:

- `Investigate the auth service before I modify it.`
- `Review this PR with Context Engine context.`
- `Check the blast radius if checkout changes.`
- `Find prior incidents related to timeout spikes.`

### Core skill map

| Skill | Best for | Example ask |
|-------|----------|-------------|
| `ctx` | General entry point | `Use Context Engine to help me understand this change.` |
| `search-knowledge` | Search docs, ADRs, patterns, teams | `Find docs about rate limiting.` |
| `investigate-service` | Service deep dives | `Investigate payments-api.` |
| `review-pr` | Context-rich code review | `Review this PR using Context Engine.` |
| `blast-radius` | Change impact analysis | `What breaks if auth-service changes?` |
| `incident-response` | Runbooks and escalation context | `Give me incident context for checkout-service.` |
| `understand-flow` | Business flow understanding | `Explain the checkout flow end to end.` |
| `dependency-check` | Dependency health and migration risk | `Check if this dependency is risky or deprecated.` |
| `code-migration` | Migration planning | `Help me migrate this service from v1 to v2.` |
| `onboard` | Guided evaluation flow | `Walk me through onboarding this project.` |

### Recommended skill-to-task mapping

| Job to be done | Start with |
|----------------|------------|
| Understanding an unfamiliar service | `investigate-service` |
| Finding docs or prior art | `search-knowledge` |
| Reviewing risky changes | `review-pr` |
| Understanding deploy risk | `blast-radius` |
| Active production incident | `incident-response` |
| Learning a business journey | `understand-flow` |
| Checking package health or migration pressure | `dependency-check` |
| Formal trial or rollout planning | `onboard` |

### Best practices for skills

- Ask for the engineering outcome, not the underlying tool.
- Include the service, flow, PR, or failure symptom when you know it.
- Use follow-up prompts to narrow the result rather than starting over.

### Examples of strong prompts

- `Investigate the service behind src/payments/processor.ts and summarize what I should know before changing it.`
- `Review this PR and highlight the riskiest files, affected services, and missing reviewers.`
- `Find incidents, docs, and ownership related to auth token expiry failures.`

---

## 5. `tabnine-ctx-loader` Manual

`tabnine-ctx-loader` is the CLI for loading engineering context into Context Engine.

### Command summary

```bash
tabnine-ctx-loader --help
```

Available commands:

| Command | What it does |
|---------|--------------|
| `init` | Generates a starter manifest |
| `validate` | Checks manifest structure |
| `load` | Runs the load |
| `status` | Shows progress or current state |
| `resume` | Continues from the last checkpoint |
| `pause` | Requests a cooperative pause |
| `cancel` | Requests a cooperative cancel |
| `rollback` | Rolls back resources created by the last run |
| `report` | Generates a staleness report |
| `schedule` | Installs or removes recurring loads |
| `diagnose` | Summarizes the latest failure |
| `query` | Searches loaded knowledge |
| `reset` | Resets the tenant to factory settings |

### 5.1 Quick-start workflow

```bash
tabnine-ctx-loader init --template minimal --output tabnine-ctx-loader.yaml
tabnine-ctx-loader validate --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader load --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader status --summary
```

### 5.2 `init`

Use `init` to generate a manifest from a template.

```bash
tabnine-ctx-loader init --template minimal --output tabnine-ctx-loader.yaml
```

Useful options:

| Option | Purpose |
|--------|---------|
| `--template <name>` | Choose `minimal`, `github-jira-slack`, or `gitlab-linear-pagerduty` |
| `--output <path>` | Write to a custom file |
| `--owner <org>` | Fill the GitHub owner |
| `--repo <name>` | Fill the GitHub repository |
| `--set KEY=VALUE` | Inject template values |
| `--resolve` | Resolve values from env and `ctx-settings.yaml` immediately |

Examples:

```bash
tabnine-ctx-loader init --template minimal --owner acme --repo storefront --output tabnine-ctx-loader.yaml
tabnine-ctx-loader init --template github-jira-slack --resolve --output tabnine-ctx-loader.yaml
```

### 5.3 Templates

Available starter templates:

| Template | Best for |
|----------|----------|
| `minimal` | GitHub-only starting point |
| `github-jira-slack` | Code, issues, and team conversations |
| `gitlab-linear-pagerduty` | GitLab-centered teams with incident tooling |

### 5.4 `validate`

Validate before every load:

```bash
tabnine-ctx-loader validate --manifest tabnine-ctx-loader.yaml --json
```

Typical validation checks:

- required manifest sections exist
- credentials are referenced correctly
- source definitions are complete enough to run

### 5.5 `load`

Run the full data load:

```bash
tabnine-ctx-loader load --manifest tabnine-ctx-loader.yaml --json
```

Optional mode:

```bash
tabnine-ctx-loader load --manifest tabnine-ctx-loader.yaml --mode delta --json
```

Use `full` for first-time loads or major refreshes. Use `delta` for incremental refreshes when your manifest and schedule support it.

### 5.6 `status`

Check the current state:

```bash
tabnine-ctx-loader status --summary
```

Use JSON for automation:

```bash
tabnine-ctx-loader status --json
```

### 5.7 `resume`, `pause`, and `cancel`

Use these when a load is interrupted or needs to be controlled.

```bash
tabnine-ctx-loader resume --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader pause --json
tabnine-ctx-loader cancel --json
```

Use `resume` after temporary interruptions. Use `pause` or `cancel` when you want the run to stop cleanly at a safe boundary.

### 5.8 `rollback`

Rollback the last run:

```bash
tabnine-ctx-loader rollback --manifest tabnine-ctx-loader.yaml --json
```

Use this when a recent load created incorrect or unwanted data and you want to undo only that run.

### 5.9 `report`

Check freshness:

```bash
tabnine-ctx-loader report --json
```

Use this to see whether sources are stale and need a refresh.

### 5.10 `schedule`

Install a recurring load:

```bash
tabnine-ctx-loader schedule --manifest tabnine-ctx-loader.yaml --daemon --json
```

Remove it:

```bash
tabnine-ctx-loader schedule --remove --json
```

Use scheduled loads for teams that want context to stay current without manual reloads.

### 5.11 `diagnose`

Start here when a load fails:

```bash
tabnine-ctx-loader diagnose --json
```

This is the fastest way to get a concise summary of what went wrong in the latest run.

### 5.12 `query`

Use `query` to inspect what is already loaded.

Semantic search:

```bash
tabnine-ctx-loader query search "database sharding strategy"
```

Filter by entity type:

```bash
tabnine-ctx-loader query entities --type Service --search "payment"
```

Inspect one entity:

```bash
tabnine-ctx-loader query entity <entity-id>
```

### 5.13 `reset`

```bash
tabnine-ctx-loader reset
```

This is destructive. Use it only when you intend to clear the tenant and start over.

### 5.14 Manifest structure

A loader manifest is the file that describes what to load.

High-level structure:

```yaml
version: '1.0'
metadata:
  name: my-project
ctx:
  apiUrl: ${CTX_API_URL}
  apiKey: ${CTX_API_KEY}
credentials:
  github:
    type: github_pat
    data:
      token: ${GH_PAT}
workspaces:
  main:
    sources:
      - name: code
        type: github
        credential: github
        config:
          owner: ${GITHUB_ORG}
          repo: ${GITHUB_REPO}
```

Key sections:

| Section | Purpose |
|---------|---------|
| `metadata` | Project name and environment label |
| `ctx` | Context Engine connection |
| `credentials` | Tokens or auth definitions by name |
| `workspaces` | Logical groups of sources |
| `sources` | Actual repositories, issue systems, chat systems, or on-call systems |
| `schedule` | Optional recurring load definitions |

### 5.15 Recommended loader patterns

| Situation | Recommendation |
|-----------|----------------|
| First evaluation | Start with `minimal` or one code source |
| Broad pilot | Add Jira or Linear plus one communication source |
| Incident-heavy teams | Add PagerDuty or equivalent early |
| Low-confidence answers | Expand beyond code-only sources |

---

## 6. `tabnine-ctx-onboard` Manual

`tabnine-ctx-onboard` runs the structured evaluation flow for the Customer Pack.

### Command summary

```bash
tabnine-ctx-onboard --help
```

Available commands:

| Command | Purpose |
|---------|---------|
| `step-0` | Validate setup and detect capabilities |
| `step-1` | Build a testing lab |
| `step-2` | Load project data |
| `step-3` | Score baseline answers without Context Engine |
| `step-4` | Score answers with Context Engine |
| `step-5` | Add domain enrichment |
| `step-6` | Re-score with domain enrichment |
| `step-7` | Generate a rollout plan |
| `status` | Show progress |
| `reset` | Reset onboarding state |
| `query` | Search the loaded knowledge during onboarding |

### 6.1 Recommended paths

Quick evaluation:

```bash
tabnine-ctx-onboard step-0 --json
tabnine-ctx-onboard step-1 --repo-path . --json
tabnine-ctx-onboard step-2 --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-onboard step-3 --json
tabnine-ctx-onboard step-4 --json
tabnine-ctx-onboard step-7 --json
```

Full evaluation:

```bash
tabnine-ctx-onboard step-0 --json
tabnine-ctx-onboard step-1 --repo-path . --json
tabnine-ctx-onboard step-2 --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-onboard step-3 --json
tabnine-ctx-onboard step-4 --json
tabnine-ctx-onboard step-5 --repo-path . --json
tabnine-ctx-onboard step-6 --json
tabnine-ctx-onboard step-7 --json
```

### 6.2 Step reference

#### `step-0`

```bash
tabnine-ctx-onboard step-0 --json
```

Use this first. It confirms connectivity and reports what capabilities are available for the later steps.

#### `step-1`

```bash
tabnine-ctx-onboard step-1 --repo-path . --json
```

This generates a test plan from your repository so the evaluation uses realistic questions.

#### `step-2`

```bash
tabnine-ctx-onboard step-2 --manifest tabnine-ctx-loader.yaml --json
```

This starts the load in the background.

Check status:

```bash
tabnine-ctx-onboard step-2 --status --json
```

Use this form until the load completes.

#### `step-3`

```bash
tabnine-ctx-onboard step-3 --json
```

This returns the evaluation questions for the no-Context-Engine baseline.

After you prepare the response file:

```bash
tabnine-ctx-onboard step-3 --responses .tabnine-ctx-onboarding/step3-answers.json --json
```

#### `step-4`

```bash
tabnine-ctx-onboard step-4 --json
```

This uses the same test plan, but now answers should use loaded Context Engine knowledge.

Submit the results:

```bash
tabnine-ctx-onboard step-4 --responses .tabnine-ctx-onboarding/step4-answers.json --json
```

#### `step-5`

```bash
tabnine-ctx-onboard step-5 --repo-path . --json
```

Use `--dry-run` first if you want to preview the generated domain model:

```bash
tabnine-ctx-onboard step-5 --repo-path . --dry-run --json
```

#### `step-6`

```bash
tabnine-ctx-onboard step-6 --json
```

Submit the enriched answers:

```bash
tabnine-ctx-onboard step-6 --responses .tabnine-ctx-onboarding/step6-answers.json --json
```

#### `step-7`

```bash
tabnine-ctx-onboard step-7 --json
```

This generates the adoption and rollout guidance based on the measured results.

### 6.3 `status`

```bash
tabnine-ctx-onboard status
```

Use the plain output for a readable progress view. Use `--json` for automation or scripting.

### 6.4 `query`

During onboarding, use the built-in query helpers to inspect the loaded graph:

```bash
tabnine-ctx-onboard query search "service architecture"
tabnine-ctx-onboard query entities --type Service --limit 20
tabnine-ctx-onboard query entity <entity-id>
```

### 6.5 What onboarding creates for you

During a normal run you can expect these customer-visible artifacts:

| Artifact | Purpose |
|----------|---------|
| `tabnine-ctx-loader.yaml` | What will be loaded |
| `.tabnine-ctx-onboarding/test-plan.yaml` | Generated evaluation questions |
| `.tabnine-ctx-onboarding/domain-model.yaml` | Generated domain enrichment output |

### 6.6 When to choose the quick path vs full path

| Use case | Best path |
|----------|-----------|
| Fast technical validation | Quick path |
| Leadership-ready adoption case | Full path |
| Domain-heavy platform or product | Full path |
| Small repo or early pilot | Quick path first, full path later |

---

## 7. Common Customer Workflows

### Workflow: day-to-day coding support

Use `ctx-skills`.

Best first asks:

- `Investigate this service before I change it.`
- `Find docs or incidents related to this failure.`
- `Review this PR with architecture context.`

### Workflow: setting up a new project

Use `tabnine-ctx-loader`.

Recommended sequence:

```bash
tabnine-ctx-loader init --template minimal --output tabnine-ctx-loader.yaml
tabnine-ctx-loader validate --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader load --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader status --summary
```

### Workflow: proving value to stakeholders

Use `tabnine-ctx-onboard`.

Recommended sequence:

```bash
tabnine-ctx-onboard step-0 --json
tabnine-ctx-onboard step-1 --repo-path . --json
tabnine-ctx-onboard step-2 --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-onboard step-3 --json
tabnine-ctx-onboard step-4 --json
tabnine-ctx-onboard step-7 --json
```

### Workflow: stale or weak answers

Usually the next move is not a different prompt. It is one of:

- refresh with `tabnine-ctx-loader load --mode delta --manifest tabnine-ctx-loader.yaml --json`
- add more sources to the manifest
- confirm the right project directory has the right `ctx-settings.yaml`

---

## 8. Troubleshooting

### Problem: the agent answers generically

Check:

```bash
tabnine-ctx-loader status --summary
tabnine-ctx-loader query entities --type Service --limit 10
```

Likely causes:

- no data was loaded
- data is stale
- the wrong repository or workspace was loaded

### Problem: validation fails

Check for:

- missing credential values in `ctx-settings.yaml`
- manifest credentials that do not match source references
- missing required source configuration such as repo owner, repo name, or project IDs

### Problem: a load takes a long time

This is normal for larger repositories and multi-source manifests. Use:

```bash
tabnine-ctx-loader status --summary
```

Or, in onboarding:

```bash
tabnine-ctx-onboard step-2 --status --json
```

### Problem: a load failed

Start here:

```bash
tabnine-ctx-loader diagnose --json
```

Then decide whether to:

- fix credentials and re-run
- use `resume`
- reduce scope temporarily for the initial load

### Problem: onboarding seems stuck at step 2

Remember that `step-2` starts a background load. Poll using:

```bash
tabnine-ctx-onboard step-2 --status --json
```

### Problem: you need to start over

Use with care:

```bash
tabnine-ctx-onboard reset
tabnine-ctx-loader reset
```

`tabnine-ctx-loader reset` is destructive because it clears tenant data.

---

## 9. Safety Notes

- Keep secrets in `ctx-settings.yaml` or environment variables.
- Do not pass API keys or tokens as CLI arguments.
- Validate manifests before loading.
- Use `diagnose` before retrying repeatedly.
- Treat `reset` as a deliberate administrator action.

---

## 10. Companion Docs

- `docs/customer-pack-user-guide.md` for tutorials and first-run workflows
- `docs/onboarding-guide.md` for a longer onboarding walkthrough
- `docs/context-engine-guide.md` for broader Context Engine query patterns
