# Context Engine User Guide

The Context Engine is a knowledge graph platform by Tabnine that connects your AI coding agent to your organization's full engineering context -- services, dependencies, incidents, ADRs, ownership, flows, and more. Instead of answering questions from general knowledge alone, your AI agent can query real data about your specific codebase, architecture, and operational history.

This guide is for developers using an AI coding agent (Claude Code, Cursor, Gemini CLI, Tabnine, or others) with Context Engine integration. It covers installation, core concepts, practical workflows, data loading, and a complete tool reference.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Core Concepts](#core-concepts)
- [Workflow Guides](#workflow-guides)
  - [Investigating a Service](#investigating-a-service)
  - [Reviewing Pull Requests](#reviewing-pull-requests)
  - [Assessing Blast Radius](#assessing-blast-radius)
  - [Incident Response](#incident-response)
  - [Understanding Business Flows](#understanding-business-flows)
  - [Checking Dependencies](#checking-dependencies)
  - [Code Migration](#code-migration)
  - [Searching Knowledge](#searching-knowledge)
  - [Exploring the Graph](#exploring-the-graph)
  - [Ownership and Teams](#ownership-and-teams)
  - [Git Insights](#git-insights)
  - [Feature Development](#feature-development)
  - [Working with Jira](#working-with-jira)
  - [Working with Slack](#working-with-slack)
  - [Working with Confluence](#working-with-confluence)
  - [Working with GitLab](#working-with-gitlab)
- [Data Loading](#data-loading)
- [Running Agents](#running-agents)
- [Tool Reference](#tool-reference)
- [Troubleshooting](#troubleshooting)
- [Appendix: Supported AI Agents](#appendix-supported-ai-agents)

---

## Getting Started

### Prerequisites

Before you begin, you need:

1. **Context Engine server access** -- a URL and API key provided by your organization (e.g., `https://ctx.your-company.com`).
2. **A supported AI coding agent** -- see [Supported AI Agents](#appendix-supported-ai-agents) for the full list.
3. **Network access** to your Context Engine server. If your organization uses a proxy or custom CA certificates, you will need those details as well.

### Installation

#### curl | bash (recommended)

**Core only** -- skills for your AI agent:

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package core --agent claude
```

**Core + data loader CLI:**

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package loader --agent claude
```

**Everything** (core + loader + onboarding):

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

The installer fetches files directly from GitHub -- no clone needed. Dependency resolution is automatic: `loader` includes `core`, `all` includes everything. Replace `claude` with `cursor`, `gemini`, or `tabnine` for other agents.

#### Claude Code plugin

```bash
claude plugin install --from https://github.com/codota/ctx-customer-pack-distributable
```

Installs the full plugin bundle: 37 skills + hooks + MCP server. The loader and onboarder are CLI tools -- use the `curl | bash` installer to add them.

### Configuration

Set the following environment variables:

```bash
export CTX_API_URL=https://ctx.your-company.com
export CTX_API_KEY=ctx_your_key_here
```

| Variable | Required | Description |
|----------|----------|-------------|
| `CTX_API_URL` | Yes | Context Engine server URL |
| `CTX_API_KEY` | Yes | API key (never pass as a CLI flag) |
| `HTTPS_PROXY` | No | HTTP proxy for corporate networks |
| `NODE_EXTRA_CA_CERTS` | No | Custom CA certificate path |

### Verifying Your Setup

Run these commands to confirm everything is working:

```bash
# List all available MCP tools
ctx-cli mcp list

# Test connectivity with a simple search
ctx-cli mcp call search_knowledge -p query="hello" -o json

# Inspect a specific tool
ctx-cli mcp describe investigate_service
```

If `search_knowledge` returns results, your connection is working. If it returns an empty result set, data may not have been loaded yet -- see [Data Loading](#data-loading).

---

## Core Concepts

### The Knowledge Graph

The Context Engine builds a knowledge graph from your organization's data sources -- GitHub repositories, Jira projects, Slack channels, PagerDuty services, Confluence spaces, and more. The graph stores:

- **Entities** (nodes) -- services, teams, flows, ADRs, incidents, runbooks, code modules, packages, vulnerabilities, and other domain objects.
- **Relationships** (edges) -- connections between entities such as `depends_on`, `calls`, `contains`, `manages`, `owns`, `references`, and more.

Everything in the graph is queryable through MCP tools exposed to your AI agent.

### Key Entity Types

| Entity Type | Description |
|-------------|-------------|
| Service | A deployed service or microservice |
| Team | An engineering team with ownership and contacts |
| Flow / CriticalFlow | A business process spanning multiple services |
| ADR | Architecture Decision Record |
| Incident | A past production incident with root cause and timeline |
| Runbook | Operational runbook for a service or scenario |
| SecurityPattern | Security best practices and anti-patterns |
| CodeModule | File pattern mapping to a service or package |
| CodeHotspot | Frequently changed file with high churn |
| CodeExpert | Developer with deep knowledge of a code area |
| CodeCoupling | Files that frequently change together |
| ModuleBoundary | Logical module boundary detected from co-change patterns |
| Package | A library dependency (npm, maven, pypi, etc.) |
| Vulnerability | A known CVE or security advisory |
| Feature | A tracked development feature |
| SemanticDomain | A cross-cutting concern (e.g., rate-limiting, authentication) |
| SemanticConcept | An abstract concept within a domain |
| Documentation | Indexed documentation pages |

### Relationship Types

Common edge types you will encounter when traversing the graph:

| Edge Type | Description |
|-----------|-------------|
| `depends_on` | Service or package dependency |
| `calls` | HTTP/gRPC call between services |
| `contains` | Parent-child containment |
| `manages` | Team manages a service |
| `owns` | Ownership relationship |
| `references` | Entity references another |
| `produces` / `consumes` | Message topic publish/subscribe |
| `created_together` | Files that change together |

### MCP Tool Invocation

All Context Engine tools are invoked through the MCP (Model Context Protocol) interface. The general pattern is:

```bash
ctx-cli mcp call <tool_name> -p <param>=<value> -o json
```

Your AI agent calls these tools automatically when you ask questions. You can also invoke them directly from the command line for testing or scripting.

### Composite vs. Granular Tools

The Context Engine provides two tiers of tools:

- **Composite skills** aggregate multiple data sources into a single call. These are the tools you should reach for first:
  - `investigate_service` -- everything about a service in one call
  - `blast_radius` -- full impact analysis for a change
  - `incident_response` -- everything needed during an incident
  - `code_migration` -- complete migration guidance
  - `dependency_check` -- full health assessment for a package
  - `understand_flow` -- end-to-end business flow analysis

- **Granular tools** provide targeted access to specific data. Use these when you need just one piece of information or are building custom queries.

### Hooks

Two hooks run automatically when installed:

- **decision-context** -- fires when your agent edits or writes a file. Surfaces relevant ADRs, past incidents, security patterns, and ownership for the file being modified.
- **change-confidence** -- fires when you commit code. Returns a risk score (0-100) for the staged files based on churn, blast radius, historical incidents, and expert coverage.

These hooks never block your agent. They add context to help you make better decisions.

---

## Workflow Guides

These guides are organized by task. Each shows which tools to use, in what order, with example commands.

### Investigating a Service

Use `investigate_service` as your starting point whenever you need to understand a service.

```bash
ctx-cli mcp call investigate_service -p serviceName=payments-api -o json
```

This returns:

- **Dependencies** -- upstream services this service calls
- **Dependents** -- downstream services that call this service
- **Ownership** -- team, on-call contacts, escalation paths
- **ADRs** -- architecture decision records related to the service
- **Incidents** -- recent incidents involving this service
- **Documentation** -- runbooks, flows, and indexed docs
- **Issues** -- active Jira and GitLab issues

For targeted queries, use the granular tools:

```bash
# Quick service overview without full documentation
ctx-cli mcp call get_service_context -p serviceName=payments-api -o json

# Just the dependencies (what it calls)
ctx-cli mcp call get_service_dependencies -p serviceName=payments-api -o json

# Just the dependents (what calls it)
ctx-cli mcp call get_service_dependents -p serviceName=payments-api -o json

# Browse all services
ctx-cli mcp call list_services -o json

# Filter by team or tier
ctx-cli mcp call list_services -p team=Commerce -p tier=critical -o json
```

### Reviewing Pull Requests

Follow this five-step workflow for context-rich PR reviews:

**Step 1: Check change confidence for each changed file.**

```bash
ctx-cli mcp call get_change_confidence -p files='["src/payments/processor.ts", "src/checkout/cart.ts"]' -o json
```

The confidence score tells you where to focus:

| Score | Level | Action |
|-------|-------|--------|
| 90-100 | GREEN | Low risk, safe to merge |
| 75-89 | YELLOW | Moderate risk, review carefully |
| 50-74 | ORANGE | High risk, extensive testing needed |
| 0-49 | RED | Critical risk, escalation recommended |

**Step 2: Get architectural context for high-risk files.**

```bash
ctx-cli mcp call get_file_context -p filepath=src/payments/processor.ts -o json
```

Returns the service the file belongs to, relevant ADRs, past incidents, security patterns, code experts, and blast radius.

**Step 3: Check blast radius for affected services.**

```bash
ctx-cli mcp call blast_radius -p target=payments-api -o json
```

**Step 4: Find suggested reviewers.**

```bash
ctx-cli mcp call get_code_reviewers -p path=src/payments/processor.ts -o json
```

**Step 5: Get detailed risk factors for specific files.**

```bash
ctx-cli mcp call get_file_risk_factors -p filepath=src/payments/processor.ts -o json
```

Returns churn metrics, bug-fix ratio, author analysis, and coupling data.

### Assessing Blast Radius

Before deploying changes to shared or core services, check the blast radius:

```bash
ctx-cli mcp call blast_radius -p target=payments-api -o json
```

The response includes:

- **Affected services** -- direct and transitive dependents
- **Affected flows** -- business flows that traverse this service
- **Affected teams** -- teams that own impacted services
- **Risk level** -- overall risk assessment (low, medium, high, critical)

Use the `changeType` parameter for more specific risk assessment:

```bash
# Assess impact of a breaking change
ctx-cli mcp call blast_radius -p target=auth-service -p changeType=breaking -o json

# Assess impact of a deprecation
ctx-cli mcp call blast_radius -p target=legacy-gateway -p changeType=deprecation -o json
```

Extract specific sections with jq:

```bash
# Just the affected teams
ctx-cli mcp call blast_radius -p target=auth-service -o json | jq '.affected_teams'

# Count affected flows
ctx-cli mcp call blast_radius -p target=order-service -o json | jq '.affected_flows | length'
```

### Incident Response

During an active incident, start with `incident_response`:

```bash
ctx-cli mcp call incident_response -p service=checkout-service -o json
```

This returns everything you need:

- **Runbooks** -- operational runbook steps and commands
- **Escalation contacts** -- on-call engineers, team leads, escalation paths
- **Recent incidents** -- past incidents with timelines and root causes
- **Known failure modes** -- documented failure patterns and mitigations

Include a symptom for better incident matching:

```bash
ctx-cli mcp call incident_response -p service=payments-api -p symptom="5xx errors" -o json
```

**Follow-up actions during the incident:**

Search for similar past incidents:

```bash
ctx-cli mcp call search_incidents -p query="timeout" -p service=checkout -o json
```

Acknowledge and add notes to PagerDuty:

```bash
ctx-cli mcp call acknowledge_pagerduty_incident -p incidentId=P1234567 -p requesterEmail=you@company.com -o json

ctx-cli mcp call add_pagerduty_note -p incidentId=P1234567 -p content="Investigating database connection pool exhaustion" -p requesterEmail=you@company.com -o json
```

Or manage Opsgenie alerts:

```bash
ctx-cli mcp call acknowledge_opsgenie_alert -p alertId=abc-123 -o json

ctx-cli mcp call add_opsgenie_note -p alertId=abc-123 -p note="Root cause identified: connection pool misconfiguration" -o json
```

Create follow-up tickets:

```bash
ctx-cli mcp call create_jira_issue -p project_key=PAY -p summary="Fix connection pool exhaustion under load" -p description="Root cause from INC-456" -p issue_type=Bug -o json
```

Resolve the incident:

```bash
ctx-cli mcp call resolve_pagerduty_incident -p incidentId=P1234567 -p requesterEmail=you@company.com -p resolution="Connection pool max size increased from 10 to 50" -o json
```

### Understanding Business Flows

Trace a business flow end-to-end:

```bash
ctx-cli mcp call understand_flow -p flowName=checkout -o json
```

Returns:

- **Services** -- ordered list of services the flow traverses
- **ADRs** -- architecture decisions relevant to the flow
- **Incidents** -- past incidents that affected this flow
- **SLOs** -- service-level objectives for the flow

Discover available flows:

```bash
# List all flows
ctx-cli mcp call list_flows -o json

# Filter to flows spanning 3+ services
ctx-cli mcp call list_flows -p minServices=3 -o json

# Search by keyword
ctx-cli mcp call search_flows -p query="payment" -o json

# Find flows a specific service participates in
ctx-cli mcp call get_service_flows -p serviceName=order-service -o json
```

### Checking Dependencies

Get a complete health assessment for a package:

```bash
ctx-cli mcp call dependency_check -p packageName=lodash -o json
```

Returns:

- **Vulnerabilities** -- known CVEs and security advisories
- **Upgrade history** -- did past upgrades require code changes?
- **Migration examples** -- how other teams migrated away
- **Recommended alternatives** -- internal packages to use instead

For deeper security analysis:

```bash
# Get vulnerabilities for a specific package
ctx-cli mcp call get_package_vulnerabilities -p packageName=lodash -o json

# Check the blast radius of a specific CVE
ctx-cli mcp call get_cve_blast_radius -p cveId=CVE-2020-8203 -o json

# List all known vulnerabilities
ctx-cli mcp call list_all_vulnerabilities -o json

# Check CVE resolution status
ctx-cli mcp call get_cve_resolution_status -p cveId=CVE-2020-8203 -o json
```

For upgrade planning:

```bash
# Check if past upgrades required code changes
ctx-cli mcp call get_package_upgrade_history -p packageName=typescript -o json

# Find upgrades that caused code changes (problematic dependencies)
ctx-cli mcp call get_upgrades_with_code_changes -o json

# Find safe-to-auto-merge upgrades
ctx-cli mcp call get_upgrades_without_code_changes -o json

# Get major version upgrades with breaking changes
ctx-cli mcp call get_major_upgrades -o json

# Find recommended internal alternatives
ctx-cli mcp call get_recommended_packages -p capability="HTTP client" -o json
```

### Code Migration

Get complete migration guidance:

```bash
ctx-cli mcp call code_migration -p fromPackage=moment -p toPackage=date-fns -o json
```

Returns:

- **Field mappings** -- equivalent fields between old and new packages
- **Migration examples** -- services that have already migrated
- **Breaking changes** -- fields removed or renamed
- **Adoption status** -- which services have migrated vs. still pending

Track migration progress:

```bash
# Check adoption of a replacement package
ctx-cli mcp call get_adoption_status -p packageName=@acme/http-client -o json

# Check migration status from a deprecated package
ctx-cli mcp call get_migration_status -p oldPackage=axios -p newPackage=@acme/http-client -o json

# Find equivalent fields across repos
ctx-cli mcp call find_equivalent_fields -p fieldName=windowMs -o json
```

### Searching Knowledge

Three search approaches for different needs:

**Semantic search** across all knowledge:

```bash
ctx-cli mcp call search_knowledge -p query="rate limiting strategy" -o json
```

**Entity search** with type filtering:

```bash
# Find services by keyword
ctx-cli mcp call find_entities -p query="payment" -p entityTypes='["Service"]' -o json

# Find code patterns
ctx-cli mcp call find_entities -p query="retry backoff" -p entityTypes='["CodePattern"]' -o json
```

**Documentation search**:

```bash
# Search all documentation types
ctx-cli mcp call search_all_documentation -p query="deployment process" -o json

# Filter to specific doc types
ctx-cli mcp call search_all_documentation -p query="auth" -p docTypes="ADR,Runbook" -o json

# Search ADRs specifically
ctx-cli mcp call search_adrs -p query="event sourcing" -o json

# Filter ADRs by status
ctx-cli mcp call search_adrs -p query="messaging" -p status=accepted -o json
```

**Structured queries**:

```bash
# Query entities by type with name pattern
ctx-cli mcp call query_entities -p entityType=Service -p namePattern="*payment*" -o json
```

**Organizational skills** from past agent runs:

```bash
ctx-cli mcp call search_skills -p query="database migration" -o json
```

### Exploring the Graph

Walk the knowledge graph step by step:

**Step 1: Find an entity.**

```bash
ctx-cli mcp call find_entities -p query="payment service" -o json
```

**Step 2: Traverse its relationships.**

```bash
# What does it depend on? (outbound edges)
ctx-cli mcp call traverse_edges -p entityId=<id-from-step-1> -p direction=out -o json

# What depends on it? (inbound edges)
ctx-cli mcp call traverse_edges -p entityId=<id-from-step-1> -p direction=in -o json

# Filter by relationship type
ctx-cli mcp call traverse_edges -p entityId=<id-from-step-1> -p edgeType=calls -o json
```

**Step 3: Get full details for any entity.**

```bash
ctx-cli mcp call get_entity_by_id -p entityId=<id> -o json
```

For multi-hop traversal, call `traverse_edges` repeatedly with the entity IDs returned from each step.

### Ownership and Teams

Find who owns what:

```bash
# Get ownership for a specific service
ctx-cli mcp call get_service_ownership -p serviceName=order-service -o json

# List all teams
ctx-cli mcp call get_all_teams -o json

# Find all services owned by a team
ctx-cli mcp call get_team_services -p teamName=Commerce -o json

# Find suggested code reviewers
ctx-cli mcp call get_code_reviewers -p path=src/payments/processor.ts -o json

# Get escalation contacts for an incident
ctx-cli mcp call get_incident_contacts -p service=checkout -p severity=SEV-1 -o json
```

### Git Insights

Analyze your codebase history. These tools require the `git-insights-analyzer` agent to have been run first.

```bash
# Repository overview
ctx-cli mcp call get_git_insights_summary -o json

# Find frequently-changed files (potential refactoring targets)
ctx-cli mcp call get_codebase_hotspots -o json

# Get risk assessment for a file
ctx-cli mcp call get_file_risk -p filePath=src/core/engine.ts -o json

# Find who knows a file best
ctx-cli mcp call get_file_experts -p filePath=src/core/engine.ts -o json

# Find developer expertise areas
ctx-cli mcp call get_author_expertise -p author="Jane Smith" -o json

# Detect hidden dependencies (files that change together across module boundaries)
ctx-cli mcp call get_coupling_issues -o json

# Discover actual module boundaries from co-change patterns
ctx-cli mcp call get_module_boundaries -o json

# Find files that co-change with a specific file
ctx-cli mcp call get_related_files -p filePath=src/core/engine.ts -o json

# See what areas are actively being worked on
ctx-cli mcp call get_recent_activity -o json
```

### Feature Development

Track a feature through its lifecycle:

```bash
# 1. Register a new feature
ctx-cli mcp call start_new_feature \
  -p featureName=add-retry-logic \
  -p branchName=feature/add-retry-logic \
  -p worktreePath=.worktrees/add-retry-logic \
  -p description="Add exponential backoff retry to payment processor" \
  -o json

# 2. Record design decisions
ctx-cli mcp call update_feature_decisions \
  -p featureName=add-retry-logic \
  -p decision="Use exponential backoff with jitter" \
  -p rationale="Prevents thundering herd on payment gateway" \
  -p alternatives="Fixed delay, linear backoff" \
  -o json

# 3. Link a PR
ctx-cli mcp call create_feature_pr \
  -p featureName=add-retry-logic \
  -p prNumber=892 \
  -p prUrl="https://github.com/acme/payments/pull/892" \
  -p prTitle="Add exponential backoff retry to payment processor" \
  -o json

# 4. Mark as merged
ctx-cli mcp call merge_feature_pr -p featureName=add-retry-logic -o json

# Retrieve feature info at any time
ctx-cli mcp call get_feature -p featureName=add-retry-logic -o json
```

### Working with Jira

```bash
# Get issue details
ctx-cli mcp call get_jira_issue -p issue_key=PAY-1234 -o json

# Create a new issue
ctx-cli mcp call create_jira_issue \
  -p project_key=PAY \
  -p summary="Fix timeout in payment retry logic" \
  -p description="The retry loop does not respect the configured backoff interval." \
  -p issue_type=Bug \
  -o json

# Transition an issue
ctx-cli mcp call transition_jira_issue -p issue_key=PAY-1234 -p transition="In Progress" -o json

# Add a comment
ctx-cli mcp call add_jira_comment \
  -p issue_key=PAY-1234 \
  -p comment="Root cause identified: missing null check in retry handler. Fix in PR #892." \
  -o json
```

### Working with Slack

```bash
# Post a message to a channel
ctx-cli mcp call post_slack_message -p channel="#incidents" -p text="Investigating elevated 5xx errors on checkout-service" -o json

# Reply in a thread
ctx-cli mcp call post_slack_message -p channel=C1234567890 -p text="Root cause identified" -p thread_ts=1234567890.123456 -o json

# Update a message
ctx-cli mcp call update_slack_message -p channel=C1234567890 -p ts=1234567890.123456 -p text="RESOLVED: Connection pool misconfiguration" -o json
```

### Working with Confluence

```bash
# Search for pages
ctx-cli mcp call search_confluence_pages -p query='space = "ENG" AND text ~ "deployment"' -o json

# Get a page
ctx-cli mcp call get_confluence_page -p pageId=12345 -o json

# Create a page
ctx-cli mcp call create_confluence_page \
  -p spaceId=12345 \
  -p title="Incident Postmortem: Checkout Timeout" \
  -p body="<h1>Summary</h1><p>On 2025-03-15...</p>" \
  -o json

# Update a page (get current version first)
ctx-cli mcp call update_confluence_page -p pageId=12345 -p title="Updated Title" -p body="<p>Updated content</p>" -p version=3 -o json

# Add a comment
ctx-cli mcp call add_confluence_comment -p pageId=12345 -p body="<p>Updated the remediation steps.</p>" -o json
```

### Working with GitLab

```bash
# Search issues linked to a service
ctx-cli mcp call search_gitlab_issues -p serviceName=order-service -p state=opened -o json

# Search issues by keyword
ctx-cli mcp call search_gitlab_issues -p query="timeout" -o json

# Create a merge request
ctx-cli mcp call create_gitlab_merge_request \
  -p projectId=123 \
  -p sourceBranch=feature/fix-timeout \
  -p targetBranch=main \
  -p title="Fix connection timeout handling" \
  -o json

# Comment on a merge request
ctx-cli mcp call add_gitlab_mr_comment -p projectId=123 -p mergeRequestIid=456 -p body="LGTM" -o json
```

---

## Data Loading

Data loading populates the knowledge graph with information from your organization's tools. Without loaded data, most tools will return empty results.

### Overview

The `ctx-loader` CLI reads a YAML manifest that defines your data sources, credentials, and sync configuration, then loads everything into the Context Engine.

### Quick Start

```bash
# 1. Create a manifest from a template
ctx-loader init --template github-jira-slack --output ctx-loader.yaml

# 2. Edit the manifest to fill in your values
# (see Manifest Format below)

# 3. Validate the manifest
ctx-loader validate --manifest ctx-loader.yaml --json

# 4. Load the data
ctx-loader load --manifest ctx-loader.yaml --json

# 5. Check status
ctx-loader status --json
```

### Available Templates

| Template | Data Sources | Best For |
|----------|-------------|----------|
| `minimal` | GitHub only | Quick start, testing |
| `github-jira-slack` | GitHub + Jira + Slack | Teams using Atlassian + GitHub |
| `gitlab-linear-pagerduty` | GitLab + Linear + PagerDuty | Teams using GitLab ecosystem |

### Manifest Format

A manifest has this structure:

```yaml
version: '1.0'
metadata:
  name: ${PROJECT_NAME:-my-project}
  environment: production
ctx:
  apiUrl: ${CTX_API_URL}
  apiKey: ${CTX_API_KEY}
networking:
  proxy: ${HTTPS_PROXY:-}
  caCertPath: ${CA_CERT_PATH:-}
defaults:
  concurrency: 4
  sinceDays: 30
credentials:
  github:
    type: github_pat
    data:
      token: ${GH_PAT}
  jira:
    type: atlassian_api_token
    data:
      email: ${JIRA_EMAIL}
      apiToken: ${JIRA_API_TOKEN}
  slack:
    type: api_key
    data:
      key: ${SLACK_BOT_TOKEN}
workspaces:
  engineering:
    sources:
      - name: code
        type: github
        credential: github
        config:
          owner: ${GITHUB_ORG}
          repo: ${GITHUB_REPO}
          events: [push, pull_request, issues]
        agents: [context-ingestor, dependency-mapper]
      - name: issues
        type: jira
        credential: jira
        config:
          projects: ${JIRA_PROJECTS}
      - name: comms
        type: slack
        credential: slack
        config:
          channels: ${SLACK_CHANNELS:-engineering,incidents}
schedule:
  incremental:
    cron: '0 2 * * *'
    mode: delta
```

Variables like `${GH_PAT}` are substituted from environment variables. Never hard-code secrets in the manifest file.

### Credential Types

| Type | Used By | Required Fields |
|------|---------|----------------|
| `github_pat` | GitHub | `token` |
| `gitlab_pat` | GitLab | `token` |
| `atlassian_api_token` | Jira, Confluence | `email`, `apiToken` |
| `api_key` | Slack, PagerDuty, Linear, Opsgenie | `key` |

### Data Source Types

| Type | Description |
|------|-------------|
| `github` | GitHub repositories (code, PRs, issues) |
| `gitlab` | GitLab repositories and merge requests |
| `jira` | Jira projects and issues |
| `slack` | Slack channels and messages |
| `pagerduty` | PagerDuty services and incidents |
| `linear` | Linear issues and projects |
| `confluence` | Confluence spaces and pages |
| `opsgenie` | Opsgenie alerts and escalations |
| `servicenow` | ServiceNow incidents and change requests |
| `jfrog` | JFrog Artifactory packages and Xray vulnerabilities |

### Scheduling Incremental Loads

The `schedule` section in your manifest configures automatic delta syncs:

```yaml
schedule:
  incremental:
    cron: '0 2 * * *'    # Run at 2 AM daily
    mode: delta           # Only load changes since last sync
```

---

## Running Agents

Server-side agents analyze your data and populate the knowledge graph with derived insights. Some tools require specific agents to have been run first.

### Discovering Agents

```bash
# List all available agents
ctx-cli mcp call list_agent_kinds -o json

# List only enabled agents
ctx-cli mcp call list_agent_kinds -p enabled=true -o json
```

### Running an Agent

```bash
# Invoke an agent
ctx-cli mcp call invoke_agent -p agentKindName=git-insights-analyzer -o json

# Check status
ctx-cli mcp call get_agent_run_status -p agentRunId=<id-from-invoke> -o json

# Get results when complete
ctx-cli mcp call get_agent_run_output -p agentRunId=<id> -p includeEntities=true -o json
```

### Common Agents

| Agent | Populates | Required By |
|-------|-----------|-------------|
| `git-insights-analyzer` | Hotspots, coupling, expertise, risk | Git Insights tools |
| `ai-readiness-analyzer` | AI readiness scores | AI Readiness tools |
| `flow-discovery-agent` | Business flows from code | Flow tools |
| `service-discovery-agent` | Services and dependencies | Service tools |
| `upgrade-history-analyzer` | Package upgrade history | Upgrade tools |
| `code-module-discovery` | File-to-service mappings | Decision Context tools |

---

## Tool Reference

Quick-lookup tables grouped by category. For detailed usage, see the [Workflow Guides](#workflow-guides) above.

### Composite Skills

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `investigate_service` | Comprehensive service investigation | `serviceName` |
| `blast_radius` | Full impact analysis for a change | `target` |
| `incident_response` | Everything needed during an incident | `service` |
| `code_migration` | Complete migration guidance | `fromPackage` |
| `dependency_check` | Full health assessment for a package | `packageName` |
| `understand_flow` | End-to-end business flow analysis | `flowName` |

### Core / Built-in

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `search_knowledge` | Semantic search across all knowledge | `query` |
| `search_skills` | Find reusable patterns from past agent runs | `query` |
| `get_coding_guidelines` | Retrieve coding guidelines and standards | -- |
| `query_entities` | Query entities by type with name pattern | `entityType` |
| `query_symbols` | Query extracted code symbols (interfaces, classes, functions) | -- |
| `get_cve_resolution_status` | CVE resolution status across repos | `cveId` |

### Services

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `list_services` | List all services with metadata | -- |
| `get_service` | Service info with relationships | `serviceName` |
| `get_service_context` | Quick service overview | `serviceName` |
| `get_service_dependencies` | What this service depends on | `serviceName` |
| `get_service_dependents` | What depends on this service | `serviceName` |

### Flows

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `list_flows` | List all business flows | -- |
| `get_flow` | Detailed flow info with steps | `flowName` |
| `get_flow_services` | Services involved in a flow | `flowName` |
| `get_service_flows` | Flows a service participates in | `serviceName` |
| `search_flows` | Search flows by keyword | `query` |

### Ownership

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_service_ownership` | Service owner, contacts, Slack, PagerDuty | `serviceName` |
| `get_all_teams` | All teams with contacts and services | -- |
| `get_team_services` | Services and packages owned by a team | `teamName` |
| `get_code_reviewers` | Suggested reviewers for a file/service | `path` |
| `get_incident_contacts` | Escalation contacts for an incident | `service` |

### Architecture

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `search_adrs` | Search ADRs by keyword | `query` |
| `search_incidents` | Search past incidents | `query` |
| `get_runbook` | Get runbook for a service/scenario | `service` |
| `get_security_patterns` | Security best practices and anti-patterns | -- |
| `search_flows` | Search flows by keyword | `query` |

### Change Confidence

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_change_confidence` | Confidence score (0-100) for a set of files | `files` |
| `get_file_risk_factors` | Detailed risk breakdown for a file | `filepath` |

### Decision Context

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_file_context` | Full decision context for a file being edited | `filepath` |
| `resolve_file_to_service` | Quick file-to-service lookup | `filepath` |
| `create_code_module` | Register file patterns to a service | `name`, `description`, `filePatterns` |
| `list_code_modules` | List all code module mappings | -- |

### Git Insights

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_git_insights_summary` | Repository analysis overview | -- |
| `get_codebase_hotspots` | Frequently changed files | -- |
| `get_file_risk` | Risk assessment for a file | `filePath` |
| `get_file_experts` | Most knowledgeable contributors for a file | `filePath` |
| `get_author_expertise` | Expertise areas for a developer | -- |
| `get_coupling_issues` | Files changing together across modules | -- |
| `get_module_boundaries` | Logical module boundaries | -- |
| `get_related_files` | Files that co-change with a file | `filePath` |
| `get_recent_activity` | Currently active development areas | -- |

### Documentation

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `search_all_documentation` | Unified search across all doc types | `query` |
| `get_service_documentation` | All docs related to a service | `serviceName` |
| `list_documentation` | Browse all indexed documentation | -- |

### Graph Traversal

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `find_entities` | Semantic entity search | `query` |
| `get_entity_by_id` | Full entity details by ID | `entityId` |
| `traverse_edges` | Walk relationships from an entity | `entityId` |

### Semantic Concepts

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `list_semantic_domains` | Cross-cutting concerns in your codebase | -- |
| `get_domain_concepts` | Concepts within a domain | `domain` |
| `search_concepts` | Search concepts by keyword | `query` |
| `get_concept_implementations` | How a concept is implemented across repos | `concept` |
| `find_equivalent_fields` | Equivalent fields across repos | `fieldName` |

### Upgrades

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_upgrade_summary` | Upgrade analysis overview | -- |
| `list_upgrades` | All upgrade events | -- |
| `get_package_upgrade_history` | Upgrade history for a package | `packageName` |
| `get_major_upgrades` | Major version upgrades with breaking changes | -- |
| `get_upgrades_with_code_changes` | Upgrades that required code changes | -- |
| `get_upgrades_without_code_changes` | Safe version bumps | -- |

### Development / Features

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `start_new_feature` | Register a new feature | `featureName`, `branchName`, `worktreePath` |
| `update_feature_decisions` | Record a design decision | `featureName`, `decision`, `rationale` |
| `create_feature_pr` | Link a PR to a feature | `featureName`, `prNumber`, `prUrl`, `prTitle` |
| `merge_feature_pr` | Mark feature as merged | `featureName` |
| `get_feature` | Retrieve feature info | `featureName` |

### Package Security (JFrog)

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `check_dependency_health` | Security and license health | `packageName`, `ecosystem` |
| `get_package_vulnerabilities` | Vulnerabilities for a package | `packageName` |
| `get_cve_blast_radius` | Transitive blast radius of a CVE | `cveId` |
| `get_transitive_dependents` | All dependents (including transitive) | `packageName` |
| `get_migration_path` | Migration guidance for a package | `fromPackage`, `ecosystem` |
| `get_migration_status` | Migration progress tracking | `oldPackage` |
| `get_migration_examples` | Services that completed a migration | `fromPackage` |
| `get_adoption_status` | Adoption tracking for a package | `packageName` |
| `get_recommended_packages` | Find internal package alternatives | `capability` |
| `get_package_usage_patterns` | How a package is used across the org | `packageName`, `ecosystem` |
| `search_internal_packages` | Search internal JFrog packages | `query` |
| `list_all_packages` | List all indexed packages | -- |
| `list_all_vulnerabilities` | List all indexed vulnerabilities | -- |

### Semantic Code (LSP)

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `semantic_find_symbol` | Find classes, functions, methods | `project_id`, `name_path_pattern` |
| `semantic_find_referencing_symbols` | Find all usages of a symbol | `project_id`, `name_path_pattern` |
| `semantic_get_symbols_overview` | Symbols defined in a file | `project_id`, `relative_path` |
| `semantic_search_for_pattern` | Regex search across a repo | `project_id`, `pattern` |
| `semantic_read_file` | Read file from connected repo | `project_id`, `relative_path` |
| `semantic_list_dir` | List directory in connected repo | `project_id`, `relative_path` |
| `semantic_replace_symbol_body` | Replace a symbol implementation | `project_id`, `name_path_pattern`, `new_body` |
| `semantic_insert_after_symbol` | Insert code after a symbol | `project_id`, `name_path_pattern`, `content` |

### Agent Orchestration

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `list_agent_kinds` | List available agents | -- |
| `invoke_agent` | Trigger an agent run | `agentKindName` or `agentKindId` |
| `get_agent_run_status` | Check agent run progress | `agentRunId` |
| `get_agent_run_output` | Get agent run results | `agentRunId` |

### AI Readiness

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_ai_readiness` | Latest AI readiness score | -- |
| `get_ai_readiness_history` | AI readiness over time | -- |

### Workflow Guides

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_workflow_guide` | Built-in workflow guides | -- |

### Jira

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_jira_issue` | Get issue details | `issue_key` |
| `create_jira_issue` | Create a new issue | `project_key`, `summary`, `issue_type` |
| `transition_jira_issue` | Move issue to a new state | `issue_key`, `transition` |
| `add_jira_comment` | Add a comment to an issue | `issue_key`, `comment` |

### GitLab

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `search_gitlab_issues` | Search GitLab issues | -- |
| `create_gitlab_merge_request` | Create a merge request | `projectId`, `sourceBranch`, `targetBranch`, `title` |
| `add_gitlab_mr_comment` | Comment on a merge request | `projectId`, `mergeRequestIid`, `body` |

### Confluence

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `search_confluence_pages` | Search pages with CQL | `query` |
| `get_confluence_page` | Get page content | `pageId` |
| `create_confluence_page` | Create a new page | `spaceId`, `title`, `body` |
| `update_confluence_page` | Update a page | `pageId`, `title`, `body`, `version` |
| `add_confluence_comment` | Add comment to a page | `pageId`, `body` |

### Slack

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `post_slack_message` | Post a message | `channel`, `text` |
| `update_slack_message` | Update a message | `channel`, `ts`, `text` |

### PagerDuty

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `acknowledge_pagerduty_incident` | Acknowledge an incident | `incidentId`, `requesterEmail` |
| `add_pagerduty_note` | Add note to an incident | `incidentId`, `content`, `requesterEmail` |
| `resolve_pagerduty_incident` | Resolve an incident | `incidentId`, `requesterEmail` |

### Opsgenie

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `get_opsgenie_alert` | Get alert details | `alertId` |
| `acknowledge_opsgenie_alert` | Acknowledge an alert | `alertId` |
| `add_opsgenie_note` | Add note to an alert | `alertId`, `note` |
| `escalate_opsgenie_alert` | Escalate an alert | `alertId`, `escalationId` |
| `close_opsgenie_alert` | Close an alert | `alertId` |

### Linear

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `list_linear_teams` | List teams in workspace | -- |
| `list_linear_issues` | List recent issues | -- |
| `create_linear_issue` | Create a new issue | `title`, `teamId` |
| `update_linear_issue` | Update issue title/description | `issueId`, `title`, `description` |
| `transition_linear_issue` | Change issue state | `issueId`, `stateId` |
| `add_linear_comment` | Comment on an issue | `issueId`, `body` |

### ServiceNow

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `list_servicenow_incidents` | List/search incidents | -- |
| `create_servicenow_incident` | Create an incident | `short_description` |
| `update_servicenow_incident` | Update an incident | `sys_id` |
| `create_servicenow_change_request` | Create a change request | `short_description` |
| `add_servicenow_work_note` | Add work note to a record | `table`, `sys_id`, `work_notes` |

### GCP

| Tool | Description | Required Params |
|------|-------------|-----------------|
| `query_gcp_error_group_stats` | Error group statistics from GCP Error Reporting | `projectId` |

---

## Troubleshooting

### Connection Issues

**"Connection refused" or timeout errors:**

- Verify `CTX_API_URL` is correct and reachable: `curl -s $CTX_API_URL/health`
- Check for proxy requirements: set `HTTPS_PROXY` if behind a corporate proxy.
- Check for CA certificate requirements: set `NODE_EXTRA_CA_CERTS` for custom certs.

**"401 Unauthorized" or "Invalid API key":**

- Verify `CTX_API_KEY` is set: `echo $CTX_API_KEY`
- Ensure the key has not expired. Contact your admin for a new key.

### Tools Return Empty Results

- **Data not loaded yet** -- run `ctx-loader` to populate the knowledge graph. See [Data Loading](#data-loading).
- **Wrong service name** -- use `list_services` to discover available service names. Names support partial matching.
- **Agent not run** -- some tools require server-side agents. For example, Git Insights tools require `git-insights-analyzer`. See [Running Agents](#running-agents).

### Hooks Not Firing

- Verify plugin installation: check that skill files are in the correct agent directory.
- Ensure `CTX_API_URL` and `CTX_API_KEY` are set in the shell where your agent runs.
- Hooks run silently. Check your agent's output for "decision-context" or "change-confidence" results.

### Proxy and Certificate Issues

```bash
# Set HTTP proxy
export HTTPS_PROXY=http://proxy.company.com:8080

# Set custom CA certificate
export NODE_EXTRA_CA_CERTS=/path/to/company-ca.pem
```

Add these to your manifest's `networking` section as well:

```yaml
networking:
  proxy: ${HTTPS_PROXY:-}
  caCertPath: ${NODE_EXTRA_CA_CERTS:-}
```

---

## Appendix: Supported AI Agents

| Agent | Tier | Install Method |
|-------|------|---------------|
| Claude Code | 1 | Plugin or file copy |
| Cursor | 1 | File copy (skills + rules) |
| Gemini CLI | 1 | File copy |
| Tabnine | 1 | File copy (global) |
| GitHub Copilot | 2 (preview) | File copy |
| Codex | 2 (preview) | File copy |

Tier 1 agents are fully verified. Tier 2 agents are experimental and may have limited functionality.

---

*For evaluating Context Engine adoption with a structured methodology, see the [Onboarding Guide](onboarding-guide.md).*
