# CTX Customer Pack

Context Engine skills, data loader, and onboarding methodology for AI coding agents.

## Packages

| Package | What it includes | Depends on |
|---------|-----------------|------------|
| **core** | 37 skills, hooks, MCP proxy for your AI agent | — |
| **loader** | `ctx-loader` CLI for bulk data loading | core |
| **onboarder** | `ctx-onboard` CLI + 7-step evaluation methodology | core, loader |

## Install

### curl | bash (recommended)

**Core only** — skills for your AI agent:

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

The installer fetches files directly from GitHub — no clone needed. Dependency resolution is automatic: `loader` includes `core`, `all` includes everything. Replace `claude` with `cursor`, `gemini`, or `tabnine` for other agents.

### Claude Code plugin (core package)

```bash
claude plugin install --from https://github.com/codota/ctx-customer-pack-distributable
```

Installs the full plugin bundle via the marketplace manifest: 37 skills + hooks (decision-context, change-confidence) + MCP server (ctx-cloud). The loader and onboarder are CLI tools — use the `curl | bash` installer above to add them.

## Environment Variables

```bash
export CTX_API_URL=https://ctx.your-company.com
export CTX_API_KEY=ctx_your_key_here
```

| Variable | Required | Description |
|----------|----------|-------------|
| `CTX_API_URL` | Yes | Context Engine server URL |
| `CTX_API_KEY` | Yes | API key (never pass as CLI flag) |
| `HTTPS_PROXY` | No | HTTP proxy for corporate networks |
| `NODE_EXTRA_CA_CERTS` | No | Custom CA certificate path |

## Documentation

- [Customer Pack User Guide](docs/customer-pack-user-guide.md) — tutorials for `ctx-skills`, `ctx-loader`, and `ctx-onboard`
- [Customer Pack Manual](docs/customer-pack-manual.md) — detailed setup, command reference, and common workflows
- [Onboarding Guide](docs/onboarding-guide.md) — expanded walkthrough of the 7-step evaluation flow
- [Context Engine User Guide](docs/context-engine-guide.md) — broader Context Engine workflows and examples

## Data Loader

```bash
ctx-loader init --template github-jira-slack --output ctx-loader.yaml
ctx-loader validate --manifest ctx-loader.yaml --json
ctx-loader load --manifest ctx-loader.yaml --json
ctx-loader status --json
```

Templates in `loader/templates/`.

## Onboarding

```bash
ctx-onboard step-0 --json               # Validate setup
ctx-onboard step-1 --repo-path . --json  # Generate test plan
ctx-onboard step-2 --manifest m.yaml     # Load data
ctx-onboard step-3 --json               # Baseline (no MCP)
ctx-onboard step-4 --json               # Baseline (with MCP)
ctx-onboard step-5 --repo-path . --json  # Domain enrichment
ctx-onboard step-6 --json               # Measure with domain
ctx-onboard step-7 --json               # Rollout plan
```

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
core/agents/         37 skills × 6 agents + hooks + MCP
core/tool-schemas.json
loader/bin/ctx-loader
loader/templates/    3 manifest templates
onboarder/bin/ctx-onboard
onboarder/skills/    7 onboarding step skills
installers/install.sh
```
