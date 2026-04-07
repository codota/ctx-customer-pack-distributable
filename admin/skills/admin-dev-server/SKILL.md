---
name: admin-dev-server
description: Launch a CTX development server — start infrastructure, API server, Temporal worker, and web UI. Use this to spin up a local dev environment for testing, debugging, and live log inspection.
tags: [admin, dev, infrastructure]
group: admin
allowed-tools: Bash(make:*), Bash(pnpm:*), Bash(npm:*), Bash(docker:*), Bash(npx:*), Bash(curl:*), Bash(git:*)
---

# Admin: Dev Server

Launch and manage a local Context Engine development server. This skill starts all infrastructure (PostgreSQL, Neo4j, Temporal, ClickHouse), the API server, Temporal worker, and optionally the web UI — giving you a fully functional CTX instance for development, testing, and debugging.

## Prerequisites

- **Node.js** >= 20
- **pnpm** (`npm install -g pnpm`)
- **Docker** running with sufficient disk space
- **turbo** (`pnpm add -g turbo`)
- The CTX engine repository checked out locally

## Quick Start

From the CTX engine repository root:

```bash
# 1. Install dependencies
pnpm install

# 2. Start infrastructure (PostgreSQL x2, Neo4j, Temporal, ClickHouse, observability)
npm run infra:up

# 3. Verify containers are healthy
docker ps -a --filter "name=ctx-" --format "table {{.Names}}\t{{.Status}}"

# 4. Create a tenant (prints an API key — save it)
make create-tenant NAME=dev-tenant

# 5. Start API server + Temporal worker (background)
make dev-all

# 6. Start web UI (optional, in a separate terminal)
pnpm run dev:web
```

## Endpoints

| Service | URL | Notes |
|---------|-----|-------|
| API server | http://localhost:3005 | REST API + MCP endpoint |
| Web dashboard | http://localhost:3001 | Requires API key from step 4 |
| Neo4j browser | http://localhost:7474 | Knowledge graph (bolt: 7688) |
| Grafana | http://localhost:3000 | Metrics, logs, traces |

## Running Components Individually

```bash
pnpm run dev          # API server only (port 3005)
pnpm run dev:worker   # Temporal worker only
pnpm run dev:web      # Web UI only (port 3001)
make dev-all          # API + worker + credential proxy + MCP HTTP
```

## Checking Logs

```bash
# API server logs (live)
# If started via make dev-all, logs stream to the terminal

# Docker infrastructure logs
docker logs ctx-postgres -f --tail 50
docker logs ctx-neo4j -f --tail 50
docker logs ctx-temporal -f --tail 50

# All infrastructure container status
docker ps -a --filter "name=ctx-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## Health Checks

Once the dev server is running, verify it from another terminal:

```bash
# Basic health (no auth)
curl -s http://localhost:3005/api/health | jq .

# Detailed readiness (requires API key from tenant creation)
curl -s http://localhost:3005/api/ready -H "x-api-key: <your-api-key>" | jq .

# Or use the admin CLI
tabnine-ctx-admin health --api-url http://localhost:3005 --json
tabnine-ctx-admin ready --json
```

## Testing Against the Dev Server

Once running, you can use the full customer pack against your local instance:

```bash
# Point settings at local dev server
cat > .tabnine/ctx/ctx-settings.yaml << 'EOF'
CTX_API_URL: http://localhost:3005
CTX_API_KEY: <key from make create-tenant>
PROJECT_NAME: dev-test
GITHUB_ORG: microsoft
GITHUB_REPO: TypeScript
DATA_VOLUME: ultra-light
GH_PAT: <your-github-pat>
EOF

# Load data
tabnine-ctx-loader init --template minimal --output tabnine-ctx-loader.yaml
tabnine-ctx-loader load --manifest tabnine-ctx-loader.yaml --json

# Query the knowledge graph
tabnine-ctx-loader query search "service architecture"
tabnine-ctx-loader query entities --type Service --limit 10

# Run smoke test
tabnine-ctx-admin smoke-test --json
```

## Resetting Everything

```bash
# Reset infrastructure (tears down volumes — deletes all data)
npm run infra:reset

# Or just restart without losing data
npm run infra:up

# If Docker disk is full
docker system df                        # check usage
docker system prune -a --volumes        # free space (destroys data)
npm run infra:up                        # restart
```

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| "No space left on device" | Docker disk full | `docker system prune -a --volumes` then `npm run infra:up` |
| "workspace:*" errors | Using npm instead of pnpm | Use `pnpm install` |
| "turbo: No such file" | turbo not installed | `pnpm add -g turbo` |
| "Could not read package.json" | Wrong directory | `cd` to the ctx repo root |
| Containers show "Exited" | Infrastructure failed to start | Check `docker logs ctx-<name>`, then `npm run infra:reset` |
| API returns 401 | Wrong or missing API key | Re-run `make create-tenant NAME=dev-tenant` for a fresh key |
