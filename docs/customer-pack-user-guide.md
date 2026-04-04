# Context Engine Customer Pack User Guide

This guide is for engineers, tech leads, and platform teams using the Context Engine Customer Pack in day-to-day work. It focuses on three customer-facing parts of the pack:

- `ctx-skills` for common engineering workflows inside your AI coding agent
- `ctx-loader` for loading and refreshing engineering data
- `ctx-onboard` for running a structured evaluation and rollout plan

If you want a deeper reference for commands, configuration, and expected outputs, use the companion manual: `docs/customer-pack-manual.md`.

---

## What the Customer Pack Gives You

Use the right part of the pack for the job:

| Use this | When you want to | Best for |
|----------|------------------|----------|
| `ctx-skills` | Ask your AI agent questions using your real engineering context | Daily engineering work |
| `ctx-loader` | Load repositories, issues, chat, docs, and on-call data into Context Engine | Initial setup and refreshes |
| `ctx-onboard` | Measure impact, compare before/after results, and plan rollout | Evaluation and adoption |

The usual flow is:

1. Install the pack.
2. Create `ctx-settings.yaml`.
3. Load at least one code source with `ctx-loader`.
4. Use `ctx-skills` in your AI agent.
5. Run `ctx-onboard` if you want a formal evaluation.

---

## Before You Start

### Install

Install everything:

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

Replace `claude` with `cursor`, `gemini`, or `tabnine` if needed.

### Create `ctx-settings.yaml`

Create this file in the project directory where you plan to use the pack:

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

You only need to include credentials for the systems you actually use.

### Verify the install

```bash
which ctx-loader
which ctx-onboard
```

If both commands resolve, you are ready to go.

---

## Tutorial 1: First Value in 15 Minutes

This tutorial gets a project from zero to a working context-aware question.

### Step 1: Generate a loader manifest

For GitHub-only projects:

```bash
ctx-loader init --template minimal --output ctx-loader.yaml
```

For GitHub + Jira + Slack:

```bash
ctx-loader init --template github-jira-slack --output ctx-loader.yaml
```

### Step 2: Validate the manifest

```bash
ctx-loader validate --manifest ctx-loader.yaml --json
```

You want to see a valid manifest with the expected number of workspaces, sources, and credentials.

### Step 3: Load the data

```bash
ctx-loader load --manifest ctx-loader.yaml --json
```

Then monitor progress:

```bash
ctx-loader status --summary
```

### Step 4: Ask your first context-aware question

Once the load completes, use your AI agent with the installed `ctx-skills`.

Good first prompts:

- `Investigate the payments service before I change it.`
- `What are the main services in this repository and how do they relate?`
- `Find documentation or ADRs about rate limiting in this codebase.`

If your agent supports slash commands, you can use:

- `/investigate-service`
- `/search-knowledge`
- `/ctx`

### What success looks like

Your agent should answer with organization-specific details such as service names, ownership, dependencies, ADRs, docs, or incidents instead of only generic code reasoning.

---

## Tutorial 2: Investigate a Service Before Making Changes

Use this when you are unfamiliar with a service and want the fastest possible orientation.

### In your AI agent

Ask:

- `Investigate the checkout service and summarize dependencies, owners, docs, and recent issues.`
- `I need to modify auth-service. What should I know first?`

Best matching skills:

- `/investigate-service`
- `/ctx`

### What you should expect back

- Upstream dependencies
- Downstream dependents
- Owning team or contacts
- Relevant design docs or ADRs
- Incident history or operational notes

### Direct CLI fallback

If you want to inspect the loaded knowledge directly:

```bash
ctx-loader query search "checkout service architecture"
ctx-loader query entities --type Service --search "checkout"
```

Use this tutorial whenever you are about to touch a system you do not own or have not worked in recently.

---

## Tutorial 3: Review a Pull Request with Context

Use this when you want more than a file diff.

### In your AI agent

Ask:

- `Review this PR with Context Engine and call out risky files, architectural concerns, and likely reviewers.`
- `Use the customer-pack review workflow for these changes and tell me where to focus.`

Best matching skill:

- `/review-pr`

### What a strong result includes

- Which files look riskiest
- Which services those files belong to
- Relevant architecture decisions or prior incidents
- Which downstream services or flows may be affected
- Who is best placed to review

### Good follow-up prompts

- `Which file in this PR has the highest change risk and why?`
- `What is the blast radius if this change affects payments-api?`
- `Which reviewers have the strongest history in this area?`

This is especially useful for platform, shared library, and high-traffic services where context takes longer to rebuild than the code change itself.

---

## Tutorial 4: Check Blast Radius Before Deploying

Use this when you are changing a shared service, gateway, database integration, or authentication path.

### In your AI agent

Ask:

- `Check the blast radius for auth-service before deployment.`
- `If we change inventory-db, which services, teams, and flows could be affected?`

Best matching skill:

- `/blast-radius`

### What you want to learn

- Directly affected services
- Indirect or transitive impact
- Impacted business flows
- Teams that should know about the change
- Overall risk level

### How teams use this in practice

- Before production deploys
- During release reviews
- When deciding whether a rollback should be broad or narrow

---

## Tutorial 5: Respond to an Incident Faster

Use this when an incident is active and you need context fast.

### In your AI agent

Ask:

- `Give me incident-response context for checkout-service.`
- `We have 5xx errors in payments-api. Find runbooks, owners, and related incidents.`

Best matching skill:

- `/incident-response`

### What you should expect

- Runbooks
- Escalation contacts
- Similar past incidents
- Known failure patterns
- Relevant services or dependencies to check next

### Good follow-up prompts

- `Summarize the most likely failure modes based on similar incidents.`
- `Which team should be paged next if the first fix fails?`
- `What dependency should we inspect first?`

---

## Tutorial 6: Find Prior Art, Docs, and Patterns

Use this when you suspect somebody already solved the problem once.

### In your AI agent

Ask:

- `Search for prior art on retry backoff in our systems.`
- `Find docs, ADRs, or examples related to decorators in this codebase.`
- `Search our engineering context for database sharding guidance.`

Best matching skills:

- `/search-knowledge`
- `/ctx`

### Direct CLI fallback

```bash
ctx-loader query search "retry backoff pattern"
ctx-loader query entities --type ADR --search "event sourcing"
ctx-loader query entities --type Team --search "platform"
```

Use this workflow before writing new docs, inventing a new pattern, or opening a new design thread.

---

## Tutorial 7: Load More Than Code

Use this when answers are too code-centric and you want issues, chat, or on-call context too.

### Step 1: Start from the right template

```bash
ctx-loader init --template github-jira-slack --output ctx-loader.yaml
```

Or:

```bash
ctx-loader init --template gitlab-linear-pagerduty --output ctx-loader.yaml
```

### Step 2: Fill in the source-specific values

Typical values include:

- repository owner and repo name
- Jira projects
- Slack channels
- Linear team IDs
- PagerDuty service IDs

### Step 3: Validate and load again

```bash
ctx-loader validate --manifest ctx-loader.yaml --json
ctx-loader load --manifest ctx-loader.yaml --json
ctx-loader status --summary
```

### What improves after broader loading

- incident workflows become much stronger
- review workflows can reference issues and operational context
- search results include more than source code

---

## Tutorial 8: Run a Formal Evaluation with `ctx-onboard`

Use this when you want measured evidence for adoption instead of anecdotes.

### Recommended sequence

```bash
ctx-onboard step-0 --json
ctx-onboard step-1 --repo-path . --json
ctx-onboard step-2 --manifest ctx-loader.yaml --json
ctx-onboard step-2 --status --json
ctx-onboard step-3 --json
ctx-onboard step-4 --json
ctx-onboard step-7 --json
```

If you want the full evaluation, include:

```bash
ctx-onboard step-5 --repo-path . --json
ctx-onboard step-6 --json
```

### What each stage does

| Step | Purpose |
|------|---------|
| `step-0` | Checks connectivity and detects server capabilities |
| `step-1` | Builds a test plan from your repository |
| `step-2` | Loads project data |
| `step-3` | Scores answers without Context Engine |
| `step-4` | Scores answers with Context Engine |
| `step-5` | Adds domain enrichment |
| `step-6` | Re-scores with domain enrichment |
| `step-7` | Produces a rollout plan |

### When to use the quick path

Use steps `0, 1, 2, 3, 4, 7` when you want a fast go or no-go recommendation.

### When to use the full path

Use all seven steps when your codebase has strong internal terminology, custom frameworks, or domain-specific concepts.

---

## Everyday Prompt Patterns for `ctx-skills`

The easiest way to get value is to ask for a job, not a tool.

### Better prompts

- `Investigate the service behind this file before I edit it.`
- `Review this PR using Context Engine context.`
- `Find prior incidents or docs related to this failure.`
- `Check the blast radius if this service changes.`
- `Explain this business flow end to end.`
- `Check whether this dependency is risky or deprecated.`

### Less effective prompts

- `Call tool X.`
- `List all entities.`
- `Search something.`

The skills are most helpful when you describe the engineering task you are trying to complete.

---

## Quick Troubleshooting

### The agent gives generic answers

Likely causes:

- data has not been loaded yet
- the wrong directory is open
- `ctx-settings.yaml` is missing or incomplete

Check:

```bash
ctx-loader status --summary
ctx-loader query entities --type Service --limit 10
```

### `ctx-loader validate` fails

Usually one of these:

- required variables are missing from `ctx-settings.yaml`
- a credential name in the manifest does not match the credentials section
- a source configuration value is incomplete

### `ctx-onboard step-2` is still running

That is normal for larger repositories. Check status again:

```bash
ctx-onboard step-2 --status --json
```

### The load failed

Start here:

```bash
ctx-loader diagnose --json
```

---

## What to Read Next

- `docs/customer-pack-manual.md` for command reference and detailed setup
- `docs/onboarding-guide.md` if you want a longer walkthrough of the evaluation flow
- `docs/context-engine-guide.md` for broader Context Engine workflows and examples
