# Context Engine Admin UI Manual

This manual is a detailed reference for customers operating the Context Engine through the browser-based Admin UI.

It is intentionally limited to UI usage. It does not cover installation, infrastructure setup, or MCP client consumption. If you want the guided walkthrough first, start with [Context Engine User Guide](./context-engine-user-guide.md).

## Scope

This manual covers the Admin UI areas used to:

- connect and organize data
- manage access
- explore the knowledge graph
- define automation
- monitor runs and health
- govern credentials, keys, tools, and settings

Menu items can vary by tenant configuration, feature flags, release stage, and role. Your deployment may expose fewer or more pages than the baseline described here.

## Roles And Access

The product uses two related layers of access control.

### Tenant-wide roles

Tenant-wide roles determine what a user can do across the whole environment.

| Role | Typical use |
| --- | --- |
| `admin` | Full administration of data sources, automation, settings, keys, and system operations |
| `member` | Day-to-day use with broader write access than a viewer, depending on page permissions |
| `viewer` | Read-only or near-read-only access to available pages |

### Team roles

Team roles apply inside a specific team and its workspaces.

| Role | Typical use |
| --- | --- |
| `lead` | Can manage team members and act as the workspace owner |
| `member` | Full access to team resources |
| `viewer` | Read-only access to that team's resources |

Use tenant-wide roles to control platform authority and team roles to control workspace ownership.

## How The Admin UI Is Organized

The Admin UI follows a practical operating sequence:

1. Connect external systems.
2. Group sources into workspaces.
3. Grant workspace access to teams.
4. Validate the resulting knowledge graph.
5. Build automation on top of that data.
6. Observe health, cost, and output quality.

## Menu Map

| Area | Primary pages | What you do there |
| --- | --- | --- |
| Orientation | `Dashboard`, `Settings` | Confirm tenant health and environment state |
| Data foundation | `Connectors`, `Credentials`, `Data Sources`, `Webhook Events`, `Data Source Health` | Connect, test, sync, and troubleshoot external systems |
| Organization and access | `Workspaces`, `Teams` | Group sources and control who can see them |
| Knowledge exploration | `Semantic Search`, `Entities`, `Knowledge Graph`, `Ontology`, `Query Studio` | Search, inspect, and query the graph |
| Knowledge capture | `Artifacts`, `Memories` | Save useful outputs and durable context |
| Automation | `Agents`, `Triggers`, `Runs`, `Graph Plans`, `Plan Runs` | Define, execute, schedule, and orchestrate work |
| Tool governance | `Exported Tools`, `Extensions` | Package or expose internal retrieval logic from the UI |
| Operations and governance | `Analytics`, `Embedding Models`, `Settings` | Watch health, cost, credentials, and system configuration |

Some deployments also expose experience pages such as `Home`, `Chat`, `Workstreams`, `Missions`, `PR Reviews`, `Code Search`, `DeepWiki`, `AI Readiness`, or `Quality Machine`. Those are layered on top of the same data and automation foundation but are deployment-specific enough that this manual treats them as optional surfaces.

## Sign In, Navigation, And Session Basics

### Sign-in options

The login page supports:

- `Sign in with Tabnine`
- `Sign in with API Key`

API-key login is primarily aimed at administrators. After sign-in, the app keeps the session in browser storage until logout or key removal.

### Global navigation

The left sidebar is the primary navigation. It can be collapsed and expanded. Some sections contain nested pages, such as `Data Sources`, `Knowledge Graph`, `Analytics`, and `Settings`.

The top bar also exposes:

- `What's New`
- the glossary
- theme toggle
- user menu and logout

## Dashboard

Use `Dashboard` as the first stop for routine checks.

What it shows:

- high-level run and activity counts
- recent run activity
- data source summary
- recent runs
- entity-type summary

Use it when:

- checking whether the environment is active
- spotting broad changes in run volume
- confirming that data sources and entities are not empty after onboarding

If the dashboard looks empty when it should not, inspect `Data Sources`, `Runs`, and `Data Source Health` next.

## Connectors

Use `Connectors` to browse the supported integration catalog before you create a live connection.

Key behaviors:

- searchable and filterable catalog
- grouped by connector category
- detail cards explain what each connector is for
- `Create Data Source` launches the creation flow using the selected connector type

Use this page when a customer asks, "Can Context Engine connect to X?"

## Credentials

Use `Credentials` to store reusable secrets for external systems.

Typical tasks:

- add a new credential
- review which credential types already exist
- remove a credential that is no longer needed

Recommended practice:

- name credentials clearly
- reuse them across multiple data sources where appropriate
- rotate them centrally rather than embedding new secrets into every source

Remember that deleting a credential can break every data source that depends on it.

## Data Sources

`Data Sources` is the main integration operations page.

Common tasks:

- create a source
- search by name
- filter by connector type or sync mode
- switch between grid and list views
- sync now
- enable or disable a source
- delete an unused source

Important concepts:

| Setting | Meaning |
| --- | --- |
| `Polling` | Context Engine checks the source on an interval |
| `Webhook` | The source pushes events into Context Engine |
| `Both` | Baseline polling plus event-driven updates |

Use this page for ongoing operational control. Use the detail page when you need diagnostics or source-specific settings.

## Data Source Detail

Open a specific data source when you need deeper control.

Primary actions:

- `Edit`
- `Sync`
- `Test`
- `Enable` or `Disable`
- `Delete`

Key sections:

- `Sync Status`, `Last Sync`, `Sync Mode`, and analysis state
- connector-specific stats cards
- `Connected Ingestors`
- `Related Triggers`
- `Webhook Configuration`
- `Webhook Deliveries`
- raw configuration and metadata

### Webhook-enabled sources

When a source uses `Webhook` or `Both`, the detail page also lets you:

- copy the webhook URL
- reveal or hide the webhook secret
- copy the secret
- regenerate the secret

Regenerating the secret invalidates the old one. Update the external provider immediately after doing this.

### Git-based sources

Git-backed sources may also expose an `AI Readiness Assessment` entry point from the detail page. Use it when you want a repo-specific readiness view before you lean on AI-heavy workflows.

## Webhook Events

Use `Webhook Events` to troubleshoot delivery flow across all webhook-capable data sources.

You can filter by:

- time window
- status
- data source

This page is especially useful when:

- a provider claims it sent an event but no run started
- webhook delivery status flips between `success`, `failed`, and `rejected`
- you need to determine whether the problem is before or after ingestion

## Data Source Health

Use `Data Source Health` for a higher-level operational view than the individual data source detail page.

It provides:

- overall source health counts
- daily sync activity
- event throughput
- per-source health table
- recent sync and ingest errors

This is the best page for weekly integration reviews and for spotting slow degradation across many sources.

## Workspaces

`Workspaces` are the main organizational boundary in the product.

Use them to:

- group related data sources
- create a clean context boundary for a product, domain, or team
- support workspace-level access through teams

Typical tasks:

- create a workspace
- edit its name or description
- add data sources
- remove data sources
- delete an obsolete workspace

Recommended patterns:

- align workspaces to ownership boundaries
- keep names stable over time
- avoid excessive fragmentation

## Workspace Detail

The workspace detail page is one of the most useful operational pages in the UI because it puts several signals in one place.

You can:

- edit the workspace
- add an existing data source
- create and attach a new data source
- remove a source from the workspace without deleting the source itself
- review recent webhook activity
- review recent agent runs
- enable, disable, or delete triggers that belong to the workspace

Use this page when you want to answer, "Is this workspace healthy and active?" without jumping between several lists.

## Teams

Use `Teams` to connect people to workspaces.

The page supports two related views:

- a workspace-team management view
- a team member directory view

Typical tasks:

- create a team
- assign workspaces to the team
- add users
- change team role
- remove users
- review who belongs where

Recommended governance:

- at least one lead per important team
- team names that mirror real ownership
- no orphaned workspaces with no active team

## Semantic Search

Use `Semantic Search` for natural-language exploration of the knowledge graph.

Good use cases:

- finding services, repos, incidents, or runbooks by intent instead of exact naming
- exploratory discovery across several connected systems
- answering "where should I look?" before you jump into entities or graph views

Operational note:

If semantic search returns poor results, confirm three things before changing prompts or automation:

1. the data sources actually synced
2. the relevant entities exist
3. embedding configuration is healthy if your deployment uses semantic indexing

## Entities

`Entities` is the structured record view of the graph.

Use it to:

- browse or search for entities by name
- inspect properties and metadata
- follow related entities
- create a manual entity when appropriate

Entity detail pages are useful for debugging graph quality because they reveal what was actually stored, not just what search inferred.

## Knowledge Graph

The `Knowledge Graph` section normally includes:

- `Graph Explorer`
- `Ontology`
- `Agent Dependencies`

### Graph Explorer

Use it for relationship exploration. It is ideal when you want to see how repositories, services, incidents, packages, teams, and other entities connect.

### Ontology

Use it to understand the shape of the graph itself:

- entity types
- namespaces
- relationship types
- searchable definitions

This is the reference page for admins who want to understand what kinds of objects the platform can hold.

### Agent Dependencies

Use it to inspect how agent definitions or runtime dependencies connect, especially when debugging orchestration complexity.

## Query Studio

`Query Studio` is the advanced exploration page for saved or ad hoc graph queries.

Core actions:

- browse saved queries
- search saved queries
- edit Cypher
- enter parameters
- run the query
- save or update the query
- delete a saved query
- mark favorites
- convert a useful query into an exported tool

Use it when:

- the standard UI does not answer an operational question
- you want a repeatable internal query for admins
- you are preparing a later exported tool definition

This page is powerful but should still follow change control. Save only the queries that have clear operational value.

## Artifacts

Use `Artifacts` to manage durable outputs.

Typical actions:

- search by title
- filter by status or originating run
- open an artifact
- add a manual artifact
- delete one or many artifacts

Good uses:

- saved summaries
- generated documentation
- investigation notes
- review packages for downstream stakeholders

Artifacts are often the easiest way to turn a successful run into something a person can review later.

## Memories

Use `Memories` for durable working context.

Typical actions:

- search memories
- filter by type or importance
- create a memory
- edit a memory
- delete a memory

Good uses:

- stable team conventions
- known operational gotchas
- permanent interpretation notes for noisy systems

Keep memories concise and high-signal. Use artifacts for large documents and memories for guidance that should stay nearby during later work.

## Agents

Use `Agents` to define reusable AI workers.

Common list-page actions:

- create an agent
- search and filter
- switch between list and grid views
- enable or disable
- edit
- delete
- `Run Now`

### Key agent settings

When creating or editing an agent, expect to manage some or all of these:

- name and description
- prompt
- version
- executor type
- priority
- trigger type
- role classification
- interactive mode
- MCP tools
- additional toolboxes
- input parameters
- pipeline configuration

### Trigger choices inside an agent

An agent can be configured for:

- `Manual`
- `Data Source Events`

If you want full event routing or scheduling control across multiple agents, use the dedicated `Triggers` page instead of encoding everything into agent-local behavior.

### Pipeline configuration

Agents can trigger follow-on behavior:

- `On Complete`
- `On Entity Created`

Use pipeline rules carefully. They are powerful, but they can multiply run volume quickly if you chain them without limits.

## Agent Detail

Use the agent detail page when you need full visibility into an agent's definition.

You can inspect:

- prompt and system prompt
- MCP tools
- allowed tools
- input parameters
- output configuration
- event trigger configuration
- trigger relationships with other agents
- recent runs

This page is the best place to review whether an agent is configured the way you think it is before debugging a run.

## Triggers

Use `Triggers` when you want automation rules that are easier to monitor and test than agent-local trigger logic.

Supported trigger modes in the UI:

- `Event`
- `Cron`

Common actions:

- create
- edit
- enable or disable
- delete
- test run

Filtering options include:

- name or description
- trigger type
- enabled state
- agent
- data source
- event type

### Event triggers

Use event triggers when automation should start from incoming source events. You choose:

- data sources
- event types
- the agents to run

### Cron triggers

Use cron triggers for repeated schedules. The UI supports presets, custom cron input, and timezone selection.

Always use `Test Run` before depending on a new or edited trigger in production.

## Runs

`Runs` is the runtime operations page for agents.

Use it to:

- monitor active and recent runs
- open a specific run
- inspect logs and output
- cancel a running job
- rerun eligible jobs

### Run detail

The run detail view exposes:

- `Run Details`
- execution logs
- input and output
- created entities
- usage and budget
- agent type metadata
- live output while the run is active
- pipeline execution tree if the run is part of a larger chain

When debugging failures, start with:

1. status and timestamps
2. input payload
3. logs
4. output or missing output
5. budget and usage

## Graph Plans

Use `Graph Plans` for multi-step orchestration across the graph.

Common list-page actions:

- create a plan
- import YAML
- clone an existing plan
- enable or disable
- delete
- trigger a manual run

Graph Plans are appropriate when your workflow needs:

- more than one step
- step dependencies
- safety gates
- dry-run behavior
- event, schedule, or graph-based triggers

### Graph Plan configuration

The plan editor supports:

- ordered steps
- execution mode
- triggers
- default safety gates

Supported trigger types in the plan editor:

- `manual`
- `schedule`
- `event`
- `graph`

Use `graph` triggers when plan execution should start from changes to entities or relationships in the knowledge graph itself.

### Safety gates

Plans can define default policies for:

- external writes
- graph writes

Treat these as operational safeguards, not as decoration. They are one of the main reasons to prefer Graph Plans over ad hoc chaining.

## Plan Runs

Use `Plan Runs` to inspect executions of Graph Plans.

You can review:

- run details
- total and completed step counts
- per-step execution cards
- summary metrics
- action panels
- live state for active runs

This is the right page when a plan started but a downstream step failed or never ran.

## Exported Tools

Use `Exported Tools` to manage query- or agent-backed tools from inside the UI.

The page supports:

- create, edit, enable, disable, and delete
- test run
- search, filter, and sort
- group tools into toolboxes
- manage release stage and retriever type

Common retriever patterns in the UI include:

- graph-query-backed tools
- agent-backed tools
- prompt-backed tools
- TypeScript-backed tools
- LSP/MCP-backed retrievers

This manual stops at UI administration of exported tools. Downstream client usage belongs in your separate MCP documentation.

## Extensions

If your deployment exposes `Extensions`, use it to package related configuration into a reusable unit.

The UI supports:

- create
- edit
- import
- install
- export
- enable or disable
- delete

Extensions can bundle related items such as:

- data sources
- agents
- triggers
- exported tools

Treat extensions as packaging and reuse tools for admins, not as a replacement for workspace design.

## Analytics

The `Analytics` section usually includes:

- `Tool Usage`
- `Agent Performance`
- `Data Source Health`
- `Cost Analytics`

Use these pages together:

- `Tool Usage` tells you what the system is doing
- `Agent Performance` tells you which agents are healthy or stale
- `Data Source Health` tells you whether data is still arriving correctly
- `Cost Analytics` tells you what runtime behavior is costing

These pages are most useful when reviewed as trends, not one-off snapshots.

## Embedding Models

Use `Embedding Models` if your deployment exposes custom embedding administration.

Typical tasks:

- register a model
- test the connection
- review which models are active by scope
- delete a model and optionally its data

Only change embedding configuration with intent. It directly affects retrieval behavior, search quality, and sometimes re-indexing expectations.

## Settings

`Settings` is a mixed governance and environment page. It is one of the most important pages for administrators.

Typical sections include:

- `Agent Credentials`
- `Embeddings Credentials`
- `Text-to-Speech`
- `Appearance`
- `API Keys`
- `Tenant`
- `CTX API Key`
- `System Status`
- `Configuration`
- `Quick Help`

### Agent Credentials and runner environments

Use this section to configure the execution environments agents rely on at runtime.

Typical actions:

- add an environment
- edit an environment
- test connection
- activate or deactivate
- delete

This is the first place to inspect when runs fail because a model provider, executor, or cloud credential is misconfigured.

### Embeddings credentials

Use this section to manage credentials used specifically for embeddings or semantic retrieval. This is separate from agent runtime credentials.

### API keys

The settings UI can manage scoped API keys for programmatic access.

Common roles for keys:

- `admin`
- `member`
- `viewer`

Use scoped keys whenever possible instead of sharing a personal login.

### Tenant and CTX API key

Use these sections to:

- confirm tenant identity
- review tenant metadata
- regenerate the tenant API key if necessary

Regenerating the main API key invalidates the previous value immediately. Coordinate downstream changes before you do this.

### System status

Use this section for basic environment confidence checks before you start debugging application behavior.

## Routine Operating Procedures

### Add a new integration

1. Create or confirm the required credential.
2. Create the data source.
3. Test the data source.
4. Sync it.
5. Add it to the right workspace.
6. Review webhook configuration if applicable.
7. Confirm results in search or entities.

### Add a new team

1. Create the team.
2. Assign workspaces.
3. Add a lead.
4. Add members and viewers.
5. Confirm access with the users before closing the request.

### Launch a new automation

1. Create the agent.
2. Run it manually.
3. Review output, artifacts, and logs.
4. Add a trigger or graph plan.
5. Test the automation.
6. Watch `Runs` and `Analytics` after launch.

### Retire an obsolete object

For agents, triggers, exported tools, or data sources:

1. Disable it first.
2. Confirm nobody still depends on it.
3. Delete it only after a quiet period if risk is low.

## Troubleshooting Guide

| Symptom | First places to check |
| --- | --- |
| Data source will not sync | Data source detail, `Test`, credential validity, `Data Source Health` |
| Webhook event is missing | `Webhook Events`, webhook URL and secret, provider-side delivery logs |
| Search has poor or empty results | `Data Sources`, `Entities`, `Embedding Models`, embeddings credentials |
| Trigger never fires | Trigger enabled state, selected data sources, selected event types, `Test Run` |
| Agent fails repeatedly | Run detail logs, input payload, agent credentials, runner environment |
| User cannot see a workspace | Team membership, workspace assignment, tenant-wide role |
| Too many low-value runs | Trigger scope, cron frequency, pipeline chaining, disabled stale agents |
| Cost is rising unexpectedly | `Cost Analytics`, `Agent Performance`, recent trigger or plan changes |

## Recommended Governance Rules

- Keep workspace names stable and ownership-based.
- Reuse credentials and rotate them centrally.
- Require a manual test before enabling a new trigger.
- Review failed runs and sync errors on a schedule.
- Prefer disabling before deleting.
- Keep memories short, artifacts durable, and queries purposeful.
- Document why an exported tool or graph plan exists, not just how it works.

## What To Document Separately

Keep these topics in your separate platform or MCP documentation:

- installation and upgrades
- network and infrastructure requirements
- external MCP client setup
- CLI-only or API-only workflows
- source-system-specific secret issuance

That split keeps this manual focused on what customers can actually do inside the Admin UI.
