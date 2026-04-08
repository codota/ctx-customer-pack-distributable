# CTX Customer Pack

Context Engine skills, data loader, onboarding methodology, and admin tools for AI coding agents.

## Agent-First Onboarding

Start in your agent, not at the CLI. In Claude Code, install the full pack and ask the agent to use the built-in `onboard` skill to walk the project through the 7-step evaluation flow.

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

In Claude Code, prompt the agent with:

```text
Use the onboard skill to walk me through onboarding this project.
```

Or simply:

```text
Walk me through onboarding this project.
```

The agent-led flow validates `.tabnine/ctx/ctx-settings.yaml`, runs the onboarding steps through MCP tools, loads project data, measures baseline vs. Context Engine-assisted answers, and produces a rollout plan. If you prefer to drive each step yourself, the manual CLI path is listed in [Onboarding](#onboarding).

## Packages

| Package | What it includes | Depends on |
|---------|-----------------|------------|
| **core** | 39 skills, hooks, MCP proxy for your AI agent | — |
| **loader** | `tabnine-ctx-loader` CLI for bulk data loading + agent runs | core |
| **onboarder** | `tabnine-ctx-onboard` CLI + 7-step evaluation methodology | core, loader |
| **admin** | `tabnine-ctx-admin` CLI for tenant management, health checks, smoke tests, agent-kind management, dev server | core, loader |

## Install

### curl | bash (recommended)

**Everything** (core + loader + onboarding + admin; best choice for agent-led onboarding):

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package all --agent claude
```

**Core only** — skills for your AI agent:

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package core --agent claude
```

**Core + data loader CLI:**

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package loader --agent claude
```

**Core + loader + admin CLI:**

```bash
curl -fsSL https://raw.githubusercontent.com/codota/ctx-customer-pack-distributable/main/installers/install.sh | bash -s -- --package admin --agent claude
```

The installer fetches files directly from GitHub — no clone needed. Dependency resolution is automatic: `loader` includes `core`, `admin` includes `core` + `loader`, `all` includes everything. Replace `claude` with `cursor`, `gemini`, or `tabnine` for other agents. For onboarding in an agent, start with `--package all`.

### tabnine-ctx-cli install (minimal — ctx skill only)

If `tabnine-ctx-cli` is already installed, you can install just the core `ctx` skill:

```bash
tabnine-ctx-cli install --skills claude
```

This installs a single ctx skill for querying the knowledge graph. For the **full customer pack** (39 skills, hooks, MCP proxies, loader, onboarder, admin), use the curl installer above.

### Claude Code plugin (core package)

```bash
claude plugin install --from https://github.com/codota/ctx-customer-pack-distributable
```

Installs the full plugin bundle via the marketplace manifest: 37 skills + hooks (decision-context, change-confidence) + MCP server (tabnine-ctx-cloud). The loader and onboarder are CLI tools — use the `curl | bash` installer above to add them.

## Environment Variables

```bash
export CTX_API_URL=https://ctx.your-company.com
export CTX_API_KEY=ctx_your_key_here
```

| Variable | Required | Description |
|----------|----------|-------------|
| `CTX_API_URL` | Yes | Context Engine server URL |
| `CTX_API_KEY` | Yes | API key (never pass as CLI flag) |
| `CTX_ADMIN_SECRET` | No | Admin secret for tenant management (admin package only) |
| `HTTPS_PROXY` | No | HTTP proxy for corporate networks |
| `NODE_EXTRA_CA_CERTS` | No | Custom CA certificate path |

## Documentation

- [Customer Pack User Guide](docs/customer-pack-user-guide.md) — tutorials for `ctx-skills`, `tabnine-ctx-loader`, and `tabnine-ctx-onboard`
- [Customer Pack Manual](docs/customer-pack-manual.md) — detailed setup, command reference, and common workflows
- [Onboarding Guide](docs/onboarding-guide.md) — expanded walkthrough of the 7-step evaluation flow
- [Admin User Guide](docs/admin-user-guide.md) — setup, tenant management, smoke tests, and agent-kind management
- [Context Engine User Guide](docs/context-engine-agentic-guide.md) — broader agent workflows and Context Engine examples

## Data Loader

```bash
tabnine-ctx-loader init --template github-jira-slack --output tabnine-ctx-loader.yaml
tabnine-ctx-loader validate --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader load --manifest tabnine-ctx-loader.yaml --json
tabnine-ctx-loader status --json
```

Templates in `loader/templates/`.

## Onboarding

### In Claude Code (recommended)

Install the full pack, then ask Claude to use the `onboard` skill:

```text
Use the onboard skill to walk me through onboarding this project.
```

The agent will handle the 7-step flow with the onboarder and loader MCP tools, including setup validation, test-plan generation, data loading, evaluation, and rollout planning.

### Direct CLI (manual)

```bash
tabnine-ctx-onboard step-0 --json               # Validate setup
tabnine-ctx-onboard step-1 --repo-path . --json  # Generate test plan
tabnine-ctx-onboard step-2 --manifest m.yaml     # Load data
tabnine-ctx-onboard step-3 --json               # Baseline (no MCP)
tabnine-ctx-onboard step-4 --json               # Baseline (with MCP)
tabnine-ctx-onboard step-5 --repo-path . --json  # Domain enrichment
tabnine-ctx-onboard step-6 --json               # Measure with domain
tabnine-ctx-onboard step-7 --json               # Rollout plan
```

## Admin

```bash
tabnine-ctx-admin health --json                                    # Server liveness
tabnine-ctx-admin ready --json                                     # Detailed readiness
tabnine-ctx-admin status --json                                    # Composite dashboard
tabnine-ctx-admin create-tenant --name "Engineering" --json        # Create tenant
tabnine-ctx-admin create-api-key --tenant-id <id> --json           # Create API key
tabnine-ctx-admin configure-ai --provider anthropic_direct --json  # Configure LLM
tabnine-ctx-admin configure-embeddings --provider openai \
  --model text-embedding-3-small --dimensions 1536 --json          # Configure embeddings
tabnine-ctx-admin list-agent-kinds --json                          # List agent kinds
tabnine-ctx-admin create-agent-kind --name "my-agent" --json       # Create agent kind
tabnine-ctx-admin smoke-test --json                                # Full E2E verification
tabnine-ctx-admin dev-server --json                                # Dev server quick start
```

18 skills installed. Requires `CTX_ADMIN_SECRET` for tenant management and smoke tests. See [Admin User Guide](docs/admin-user-guide.md).

## Supported Agents

| Agent | Tier | Core install |
|-------|------|-------------|
| Claude Code | 1 | Plugin or file copy |
| Cursor | 1 | File copy (skills + rules) |
| Gemini CLI | 1 | File copy |
| Tabnine | 1 | File copy (global) |
| GitHub Copilot | 2 (preview) | File copy |
| Codex | 2 (preview) | File copy |

## Structure

```
core/agents/         39 skills × 6 agents + hooks + MCP
core/tool-schemas.json
loader/bin/tabnine-ctx-loader
loader/templates/    3 manifest templates
onboarder/bin/tabnine-ctx-onboard
onboarder/skills/    7 onboarding step skills
admin/bin/tabnine-ctx-admin
admin/skills/        18 admin skills
installers/install.sh
```
