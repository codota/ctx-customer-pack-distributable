Query the Context Engine knowledge graph — investigate services, check blast radius, search entities, manage issues, and assess change risk.

# Context Engine (ctx)

## Prerequisites

1. Install the CTX distributable (ctx-loader, ctx-onboard, ctx-cli).
2. Set the `CTX_API_KEY` and `CTX_API_URL` environment variables. Or pass them as flags: `--api-key` and `--api-url`.
3. Verify connectivity: `ctx-loader query search "hello"`

## Quick Start

```bash
# Search for any entity in the knowledge graph
ctx-loader query search "authentication" --fields entityType,entityName,similarity

# List entities by type
ctx-loader query entities --type service --search "payment"

# Investigate a service (composite tool — uses ctx-cli)
ctx-cli mcp call investigate_service -p service_name=payments-api --raw

# Check blast radius before a change
ctx-cli mcp call blast_radius -p service_name=payments-api --raw

# Get change confidence score for a file
ctx-cli mcp call get_change_confidence -p file_path=src/checkout/handler.ts --raw
```

## Searching the Knowledge Graph

Use `ctx-loader query` for all search and entity lookups. It outputs clean JSON with optional `--fields` selection.

```bash
# Free-text search
ctx-loader query search "rate limiting strategy"

# Search with field selection
ctx-loader query search "checkout" --fields entityType,entityName,similarity

# List entities by type
ctx-loader query entities --type service --limit 20

# Get a specific entity by ID
ctx-loader query entity <id>
```

## Composite Tools (via ctx-cli)

For aggregated investigations that combine multiple queries server-side, use `ctx-cli mcp call`:

```bash
# Service investigation (dependencies, ownership, incidents)
ctx-cli mcp call investigate_service -p service_name=order-service --raw

# Change confidence score
ctx-cli mcp call get_change_confidence -p file_path=src/payments/processor.ts --raw
```

## Discover Available Tools

```bash
# List all registered MCP tools
ctx-cli mcp list

# Get help for a specific tool
ctx-cli mcp describe investigate_service
```