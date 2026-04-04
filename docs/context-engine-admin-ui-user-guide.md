# Context Engine User Guide

This guide is for customers using the Context Engine through the browser-based Admin UI. It covers day-to-day setup and operation inside the product after your environment already exists.

This guide does not cover:

- installation or deployment
- MCP client setup or external agent integration
- backend-only administration

If you want the page-by-page reference manual, see [Context Engine Admin UI Manual](./context-engine-admin-ui-manual.md).

## What You Will Do

By the end of this guide, you will know how to:

- sign in and orient yourself in the UI
- add credentials and connect data sources
- group data sources into workspaces
- control access with teams
- explore the knowledge graph through search, entities, and graph views
- create agents and triggers
- monitor runs, sync health, and operating status

## Core Concepts

Before you start, it helps to use the product vocabulary the same way the UI does.

| Term | What it means in Context Engine |
| --- | --- |
| Tenant | Your organization or environment inside Context Engine |
| Credential | A reusable secret or token for an external system |
| Connector | A supported integration type, such as GitHub, Jira, Slack, or Confluence |
| Data Source | A live connection to one external system instance |
| Workspace | A grouping of data sources used for organization and access control |
| Team | A group of users that can be granted workspace access |
| Agent | An AI worker definition with a prompt, tools, trigger, and output behavior |
| Trigger | A rule that starts one or more agents when an event or schedule matches |
| Run | A single execution of an agent or orchestration plan |
| Artifact | A saved output, file, or note produced by a run or added manually |
| Memory | Durable context you want the system to keep and reuse |

## Before You Begin

Have these ready:

- your Context Engine URL
- a login method: Tabnine sign-in or an API key
- the external credentials needed for the systems you want to connect
- a simple plan for how you want to organize workspaces and teams

Good first projects are usually:

- one source code system
- one issue tracker or wiki
- one workspace
- one or two initial automations

## A Quick Tour

Most customers spend most of their time in these areas:

- `Dashboard`: overall health, recent runs, and high-level activity
- `Data Sources`: live integrations and sync controls
- `Workspaces`: how data sources are grouped
- `Teams`: who can access what
- `Semantic Search`, `Entities`, and `Knowledge Graph`: how you explore context
- `Agents`, `Triggers`, and `Runs`: how you automate work
- `Artifacts`, `Memories`, and `Query Studio`: how you capture and shape knowledge
- `Analytics` and `Settings`: how you monitor and govern the system

Not every deployment exposes every page. Menu items can vary by role, enabled features, and release stage.

## Tutorial 1: Sign In And Confirm Your Environment

Goal: get into the right tenant and confirm that the UI is healthy.

1. Open the Context Engine URL in your browser.
2. Choose `Sign in with Tabnine` or `Sign in with API Key`.
3. After login, open `Dashboard`.
4. Open `Settings` and confirm the tenant name and general environment details.
5. If you are an admin, review the `CTX API Key` and `System Status` sections.

What good looks like:

- the sidebar loads normally
- the dashboard shows cards and recent activity, even if counts are still low
- settings identify the tenant you expect

## Tutorial 2: Add Credentials And Connect Your First Data Source

Goal: create a reusable credential, then connect one source system.

### Step A: Add a credential

1. Go to `Credentials`.
2. Click `Add Credential`.
3. Choose the credential type that matches your source system.
4. Enter a clear name that other admins will recognize later.
5. Save the credential.

Tip: create one shared credential per environment or team unless a connector truly needs its own secret.

### Step B: Create the data source

1. Go to `Data Sources` and click `Add Data Source`.
2. If you are still deciding, open `Connectors` first and browse the catalog.
3. Pick the connector type.
4. Enter the data source name and connection details.
5. Choose the sync mode:
   - `Polling` for scheduled collection
   - `Webhook` for event-driven delivery
   - `Both` when you want baseline sync plus event updates
6. Attach the matching credential if the form asks for one.
7. Save.

### Step C: Validate the connection

1. Open the new data source detail page.
2. Click `Test`.
3. If the test passes, click `Sync`.
4. Review `Sync Status`, `Last Sync`, and any error banners.

If the source uses webhooks:

1. Open the `Webhook Configuration` card.
2. Copy the webhook URL and secret into the external provider.
3. Use `Webhook Deliveries` or `Webhook Events` to confirm traffic is arriving.

What good looks like:

- the data source is `Active`
- a sync completes without an error banner
- webhook sources start showing deliveries once the provider is configured

## Tutorial 3: Create A Workspace

Goal: organize data sources into a workspace that maps to a team, product area, or environment.

1. Go to `Workspaces`.
2. Click `Create Workspace`.
3. Enter a clear name and description.
4. Attach one or more data sources during creation.
5. Open the workspace detail page.
6. Use `Add Data Source` if you want to bring in additional sources later.
7. Review the workspace summary sections:
   - `Data Sources`
   - `Recent Agent Runs`
   - `Triggers`
   - `Recent Webhook Events`

Common workspace patterns:

- one workspace per product area
- one workspace per business domain
- one workspace per customer-facing platform

Avoid creating a separate workspace for every small tool unless access or ownership truly differs.

## Tutorial 4: Add Teams And Control Access

Goal: make workspaces visible to the right people.

1. Go to `Teams`.
2. Click `Create Team`.
3. Name the team and add the workspaces it should own or access.
4. Open the team and add members.
5. Choose a team role:
   - `Lead`: can manage team membership
   - `Member`: full access to team resources
   - `Viewer`: read-only access

Remember that team roles are not the same as tenant-wide roles. Someone may be a team lead inside one workspace but still have a more limited tenant role overall.

What good looks like:

- teams line up with real ownership boundaries
- workspaces are not visible to unrelated users
- every important workspace has at least one lead

## Tutorial 5: Verify That Your Context Is Useful

Goal: confirm that the system is producing searchable, navigable context.

### Semantic Search

1. Open `Semantic Search`.
2. Ask a natural-language question such as:
   - "authentication services"
   - "production incidents for payments"
   - "runbooks for deployment rollback"
3. Filter by result type if needed.

### Entities

1. Open `Entities`.
2. Search for a repository, service, incident, package, or person.
3. Open an entity to inspect metadata and related entities.

### Knowledge Graph

1. Open `Knowledge Graph` -> `Graph Explorer`.
2. Filter to the entity types you care about.
3. Expand relationships around an entity or cluster.
4. Use `Ontology` when you want to understand what kinds of nodes and relationships exist.

What good looks like:

- search returns relevant results instead of empty state
- entities show real metadata from your connected systems
- graph views reveal useful relationships across sources

If results are thin, return to `Data Sources`, `Data Source Health`, and `Webhook Events` before you keep building automation.

## Tutorial 6: Create Your First Agent

Goal: create a simple manual agent and run it once.

1. Go to `Agents`.
2. Click `Create Agent`.
3. Start with the minimum:
   - name
   - description
   - prompt
   - executor
   - priority
   - `Manual` trigger type
4. Add optional configuration only if you need it:
   - MCP tools
   - input parameters
   - additional toolboxes
   - pipeline rules
   - role classification
   - interactive mode
5. Save the agent.
6. Open the agent detail page.
7. Click `Run Agent` or `Run Now`.

Then verify the outcome:

1. Open `Runs`.
2. Open the new run detail.
3. Review `Run Details`, `Input`, `Output`, `Usage`, and logs.
4. Check `Artifacts` if the run produced saved output.

Good first agents usually do one thing well:

- summarize a data source event
- create or enrich graph entities
- analyze a repository change
- generate a reusable artifact

## Tutorial 7: Automate With A Trigger

Goal: move from manual runs to repeatable automation.

1. Go to `Triggers`.
2. Click `Create Trigger`.
3. Choose a mode:
   - `Event` for data source-driven automation
   - `Cron` for scheduled automation
4. Select the agents the trigger should run.
5. For event triggers:
   - pick the data sources
   - choose the event types
6. For cron triggers:
   - pick a preset or enter a custom cron expression
   - set the timezone
7. Save and enable the trigger.
8. Use `Test Run` to verify behavior before you rely on it in production.

What good looks like:

- test runs succeed
- the trigger is enabled
- matching events create runs in `Runs`

## Tutorial 8: Capture Knowledge With Artifacts, Memories, And Saved Queries

Goal: preserve outputs that should remain useful after one run ends.

### Artifacts

Use `Artifacts` when you want to save a document, note, or file-like output for later review.

Typical uses:

- run summaries
- investigation notes
- generated documentation
- approval records

### Memories

Use `Memories` when you want durable working knowledge the system should keep available over time.

Typical uses:

- team conventions
- persistent lessons learned
- repeated troubleshooting guidance
- special handling notes for a system

### Query Studio

Use `Query Studio` when you want to explore the graph more directly, save repeatable queries, or turn a useful query into an exported tool later.

This is especially useful for admins who want a custom operational lens without building a new page.

## Tutorial 9: Monitor Health And Operations

Goal: make sure the platform stays healthy after rollout.

Check these pages regularly:

- `Dashboard`: summary activity and recent runs
- `Data Source Health`: sync activity, throughput, source status, recent errors
- `Webhook Events`: delivery status and filters by source
- `Runs`: failures, cancellations, reruns, output quality
- `Analytics`: tool usage, agent performance, data source health, and cost
- `Settings`: tenant status, API keys, runner environments, and credentials

Suggested operating rhythm:

- daily: check failed runs and sync issues
- weekly: review health and analytics trends
- monthly: retire unused data sources, triggers, and agents

## Recommended Rollout Order

For most customers, this order creates the least friction:

1. Connect a small set of high-value data sources.
2. Create one workspace per ownership boundary.
3. Add teams and confirm access.
4. Validate search, entities, and graph quality.
5. Create one manual agent.
6. Convert that workflow into an event or cron trigger.
7. Add artifacts, memories, or saved queries where repeated work appears.

## Best Practices

- Reuse credentials instead of creating one-off secrets for every data source.
- Name workspaces, teams, data sources, and agents in a way another admin can understand instantly.
- Test new agents manually before wiring them into triggers.
- Prefer a few reliable automations over many low-signal ones.
- Use workspace boundaries for access control, not just labeling.
- Watch `Data Source Health` after changing credentials, webhook settings, or sync behavior.
- Use `Artifacts` and `Memories` to keep valuable outputs from disappearing into run history.

## When To Use The Detailed Manual

Use the manual when you need:

- a page-by-page explanation of the Admin UI
- role and permission details
- trigger, graph plan, or exported tool administration
- operational checklists and troubleshooting guidance

Continue with [Context Engine Admin UI Manual](./context-engine-admin-ui-manual.md).
