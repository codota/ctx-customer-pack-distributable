# Context Engine Admin CLI User Guide

The `tabnine-ctx-admin` CLI is for platform engineers and administrators who deploy, configure, and verify Context Engine instances. It wraps the CTX Admin REST API into composable commands for tenant management, AI provider setup, health monitoring, and end-to-end smoke testing.

| Use this | When you want to | Best for |
|----------|------------------|----------|
| `tabnine-ctx-admin health` | Check if CTX is alive | Quick liveness probe after deploy |
| `tabnine-ctx-admin smoke-test` | Verify everything works end-to-end | Post-deployment validation |
| `tabnine-ctx-admin create-tenant` | Set up a new org/team | Onboarding a new customer |
| `tabnine-ctx-admin configure-ai` | Connect an LLM provider | Initial setup or provider rotation |
| `tabnine-ctx-admin status` | Get a dashboard-style overview | Day-to-day monitoring |

---

## Before You Start

### Install

Install the admin package (includes core skills and loader):

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh \
  | bash -s -- --package admin --agent claude
```

Verify:

```bash
tabnine-ctx-admin --version
```

### Configure `ctx-settings.yaml`

Create `.tabnine/ctx/ctx-settings.yaml` in your project directory:

```yaml
CTX_API_URL: https://ctx.your-company.com
CTX_API_KEY: ctx_your_key_here
CTX_ADMIN_SECRET: your_admin_secret_here
PROJECT_NAME: my-project
```

The admin secret is required for tenant management commands (`create-tenant`, `list-tenants`, `create-api-key`). You get it from the CTX deployment's secrets (e.g., the `admin_secret_key` in the Kubernetes secret or Docker environment).

All credentials can also be set as environment variables instead:

```bash
export CTX_API_URL=https://ctx.your-company.com
export CTX_API_KEY=ctx_your_key_here
export CTX_ADMIN_SECRET=your_admin_secret_here
```

### Auth Modes

Different commands require different levels of authentication:

| Auth Level | Header | Required For |
|------------|--------|--------------|
| None | — | `health` |
| API Key | `x-api-key` | `ready`, `status`, `configure-ai`, `configure-embeddings`, `list-agent-kinds`, `create-agent-kind` |
| Admin Secret | `x-admin-secret` | `create-tenant`, `list-tenants`, `create-api-key`, `smoke-test` |

Credentials are **never** passed as CLI flags. They come from `ctx-settings.yaml` or environment variables only.

---

## Tutorial: Post-Deployment Setup

This walkthrough takes a fresh CTX deployment from "server is running" to "ready for users."

### Step 1: Verify the server is alive

```bash
tabnine-ctx-admin health --api-url https://ctx.your-company.com --json
```

Expected output:

```json
{ "status": "ok" }
```

If this fails, the server is not reachable. Check your URL and network connectivity.

### Step 2: Create a tenant

```bash
tabnine-ctx-admin create-tenant --name "Engineering" --slug "engineering" --json
```

Expected output:

```json
{ "id": "tenant-uuid-here", "name": "Engineering", "slug": "engineering" }
```

Save the tenant ID for the next step.

### Step 3: Create an API key

```bash
tabnine-ctx-admin create-api-key --tenant-id <tenant-id> --key-name "dev-key" --json
```

Expected output:

```json
{ "key": "ctx_xxxxxxxxxxxxxxxx", "name": "dev-key" }
```

This API key is what developers put in their `ctx-settings.yaml` as `CTX_API_KEY`.

### Step 4: Check detailed readiness

Update your `ctx-settings.yaml` with the new API key, then:

```bash
tabnine-ctx-admin ready --json
```

This checks whether PostgreSQL, Neo4j, Temporal, and workers are all connected and healthy.

### Step 5: Configure the AI provider

Set the Anthropic API key in your environment (never as a CLI flag):

```bash
export ANTHROPIC_API_KEY=sk-ant-api03-...
tabnine-ctx-admin configure-ai --provider anthropic_direct --json
```

### Step 6: Configure the embedding model

```bash
export OPENAI_API_KEY=sk-...
tabnine-ctx-admin configure-embeddings --provider openai --model text-embedding-3-small --dimensions 1536 --json
```

### Step 7: Verify everything

```bash
tabnine-ctx-admin status --json
```

You should see health, readiness, entity count, and data source count. The deployment is now ready for users to load data and query the knowledge graph.

---

## Tutorial: Smoke Test

The smoke test runs an 11-phase end-to-end verification. It creates a test tenant, configures AI/embeddings (if keys are available), ingests a small public GitHub repo, queries the knowledge graph, tests MCP tools, and cleans up.

### Run it

```bash
tabnine-ctx-admin smoke-test --json
```

Optional flags:

```bash
# Custom test tenant name
tabnine-ctx-admin smoke-test --tenant-name "my-smoke-test" --json

# Use a different test repo
tabnine-ctx-admin smoke-test --test-repo "microsoft/TypeScript" --json

# Keep test data after completion (for debugging)
tabnine-ctx-admin smoke-test --skip-cleanup --json
```

### What it tests

| Phase | What | Skipped If |
|-------|------|------------|
| 1. API Health | Server reachable | — |
| 2. Create Tenant | Tenant creation works | — |
| 3. Create API Key | API key generation works | — |
| 4. API Ready | All subsystems healthy | — |
| 5. Configure AI | LLM provider connection | `ANTHROPIC_API_KEY` not set |
| 6. Configure Embeddings | Embedding model connection | `OPENAI_API_KEY` not set |
| 7. Data Ingestion | Create data source + sync | — |
| 8. Entity Query | Knowledge graph populated | — |
| 9. Search | Semantic search works | — |
| 10. MCP Tools | MCP JSON-RPC responds | — |
| 11. Cleanup | Test data removed | `--skip-cleanup` used |

### Read the results

The output includes a summary:

```json
{
  "tests": [
    { "name": "API Health", "status": "pass", "durationMs": 45 },
    { "name": "Create Tenant", "status": "pass", "durationMs": 120 },
    ...
  ],
  "summary": { "passed": 9, "failed": 0, "skipped": 2, "durationMs": 32000 },
  "tenant": { "id": "...", "apiKey": "..." }
}
```

Results are also saved to `.tabnine/ctx/admin/smoke-test-result.json`.

---

## Command Reference

### Health & Status

#### `health`

Basic liveness check. No authentication required.

```bash
tabnine-ctx-admin health --api-url https://ctx.your-company.com --json
```

#### `ready`

Detailed readiness check including database, Neo4j, Temporal, and worker status.

```bash
tabnine-ctx-admin ready --json
```

#### `status`

Composite dashboard: health + readiness + entity count + data source count.

```bash
tabnine-ctx-admin status --json
```

---

### Tenant Management

#### `create-tenant`

Create a new tenant. Requires admin secret.

```bash
tabnine-ctx-admin create-tenant --name "Engineering" --slug "engineering" --json
```

| Flag | Required | Description |
|------|----------|-------------|
| `--name` | Yes | Tenant display name |
| `--slug` | No | URL-safe identifier (derived from name if omitted) |

#### `list-tenants`

List all tenants. Requires admin secret.

```bash
tabnine-ctx-admin list-tenants --json
```

#### `create-api-key`

Create an API key for a tenant. Requires admin secret.

```bash
tabnine-ctx-admin create-api-key --tenant-id <id> --key-name "prod-key" --json
```

| Flag | Required | Description |
|------|----------|-------------|
| `--tenant-id` | Yes | Tenant UUID |
| `--key-name` | No | Key label (default: "default") |

---

### AI Configuration

#### `configure-ai`

Configure the LLM provider for agent execution. The provider's API key must be set as an environment variable.

```bash
export ANTHROPIC_API_KEY=sk-ant-api03-...
tabnine-ctx-admin configure-ai --provider anthropic_direct --json
```

| Provider | Env Var |
|----------|---------|
| `anthropic_direct` | `ANTHROPIC_API_KEY` |
| `openai` | `OPENAI_API_KEY` |
| `azure_openai` | `AZURE_OPENAI_API_KEY` |

#### `configure-embeddings`

Configure the embedding model for semantic search.

```bash
export OPENAI_API_KEY=sk-...
tabnine-ctx-admin configure-embeddings --provider openai --model text-embedding-3-small --dimensions 1536 --json
```

| Flag | Required | Description |
|------|----------|-------------|
| `--provider` | Yes | Embedding provider (e.g., `openai`) |
| `--model` | Yes | Model name (e.g., `text-embedding-3-small`) |
| `--dimensions` | No | Vector dimensions (default: 1536) |

---

### Agent Kinds

#### `list-agent-kinds`

List all agent kinds registered in CTX.

```bash
tabnine-ctx-admin list-agent-kinds --json
```

#### `create-agent-kind`

Create a new agent kind.

```bash
tabnine-ctx-admin create-agent-kind \
  --name "code-reviewer" \
  --description "Reviews pull requests for security and correctness" \
  --role "reviewer" \
  --prompt "You are an expert code reviewer..." \
  --json
```

| Flag | Required | Description |
|------|----------|-------------|
| `--name` | Yes | Agent kind name |
| `--description` | No | Human-readable description |
| `--role` | No | Agent role identifier |
| `--prompt` | No | System prompt for the agent |

---

### Verification

#### `smoke-test`

Full end-to-end verification. See the [Smoke Test Tutorial](#tutorial-smoke-test) above.

```bash
tabnine-ctx-admin smoke-test --json
```

| Flag | Required | Description |
|------|----------|-------------|
| `--tenant-name` | No | Test tenant name (default: `smoke-test`) |
| `--test-repo` | No | GitHub repo for ingestion test (default: `octocat/Hello-World`) |
| `--skip-cleanup` | No | Keep test data after completion |
| `--force-lock` | No | Override existing lock file |

---

### Placeholder Commands

These commands are planned but not yet automated. Each prints an informational message explaining what it will do and exits cleanly.

| Command | Future Purpose |
|---------|---------------|
| `deploy-azure` | Automate full Azure AKS deployment lifecycle |
| `deploy-aws` | Automate AWS EKS deployment |
| `deploy-gcp` | Automate GCP GKE deployment |
| `upgrade` | In-place CTX version upgrade with migration |
| `backup` | Export tenant data + knowledge graph to archive |
| `restore` | Import from backup archive |

```bash
# See what's planned
tabnine-ctx-admin deploy-azure --json
```

---

## Global Options

Every command supports these flags:

| Flag | Description |
|------|-------------|
| `--json` | Output as JSON (machine-readable, recommended for agent use) |
| `--api-url <url>` | Override CTX API URL (global option, before the command) |

Example with global option:

```bash
tabnine-ctx-admin --api-url https://ctx.staging.example.com health --json
```

---

## Credentials & Security

### Where secrets come from

1. **`ctx-settings.yaml`** (recommended) — `.tabnine/ctx/ctx-settings.yaml` in the current directory
2. **Environment variables** — `CTX_API_URL`, `CTX_API_KEY`, `CTX_ADMIN_SECRET`
3. **Provider API keys** — `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` (environment only)

### What never goes on the command line

Secrets are **never** passed as CLI arguments. This means:
- No `--api-key` flag
- No `--admin-secret` flag
- No `--anthropic-key` flag

This prevents secrets from appearing in shell history, process listings (`ps`), and log files.

### Admin secret vs API key

- **API key** (`CTX_API_KEY`) — scoped to a single tenant. Used by developers and most admin commands.
- **Admin secret** (`CTX_ADMIN_SECRET`) — server-wide. Used only for tenant management (create/list tenants, create API keys) and smoke tests.

---

## Troubleshooting

### "No CTX settings found"

Create `.tabnine/ctx/ctx-settings.yaml` or set `CTX_API_URL` and `CTX_API_KEY` environment variables.

### "Admin secret required"

Set `CTX_ADMIN_SECRET` in `ctx-settings.yaml` or as an environment variable. You get this value from your CTX deployment secrets.

### "Provider API key required. Set ANTHROPIC_API_KEY..."

The `configure-ai` and `configure-embeddings` commands read provider API keys from environment variables, not from `ctx-settings.yaml`. Export the key before running:

```bash
export ANTHROPIC_API_KEY=sk-ant-api03-...
```

### Health check fails

- Verify the URL: `curl -sk https://ctx.your-company.com/api/health`
- Check DNS resolution and network connectivity
- If using a custom port, include it: `--api-url https://ctx.example.com:3005`

### Smoke test times out on data ingestion

The smoke test polls for sync completion for up to 5 minutes. If your CTX instance is slow or the test repo is large:
- Use a smaller repo: `--test-repo octocat/Hello-World`
- Check CTX worker logs: `kubectl logs -n ctx deployment/ctx-worker --tail=50`

---

## Agent Integration

Every admin command has a corresponding SKILL.md file, so AI coding agents can invoke them directly. When the admin package is installed, agents see skills like:

- `/admin-health` — check server health
- `/admin-smoke-test` — run full verification
- `/admin-create-tenant` — create a tenant
- `/admin-status` — get deployment status

Example agent interaction:

> "Run a smoke test against our staging CTX deployment"

The agent invokes the `admin-smoke-test` skill, which runs `tabnine-ctx-admin smoke-test --json` and reports the results.

Skills are installed automatically by the installer into the agent's skills directory (e.g., `.claude/skills/admin-smoke-test/SKILL.md`).

---

## Related Documentation

- `docs/admin/detailed-design-spec.md` — Technical design of the admin package
- `docs/customer-pack-user-guide.md` — User guide for loader, onboarder, and skills
- `docs/customer-pack-manual.md` — Full command reference for all packages
