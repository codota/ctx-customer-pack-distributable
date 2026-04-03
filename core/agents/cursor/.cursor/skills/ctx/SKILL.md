---
name: ctx
description: >-
  Query the Context Engine knowledge graph — investigate services, check blast
  radius, search entities, manage issues, and assess change risk.
tags:
  - context-engine
  - knowledge-graph
group: core
mcp-tools:
  - investigate_service
  - blast_radius
  - find_entities
  - get_change_confidence
  - search_knowledge
---
# Context Engine (ctx)

## Prerequisites

1. Install ctx-cli (see your organization's setup guide).
2. Set the `CTX_API_KEY` environment variable with your Context Engine API key.
3. Verify connectivity: `ctx-cli mcp call search_knowledge -p query="hello" -o json`

## Quick Start

```bash
# Investigate a service
ctx-cli mcp call investigate_service -p service_name=payments-api -o json

# Check blast radius before a change
ctx-cli mcp call blast_radius -p service_name=payments-api -o json

# Search for any entity in the knowledge graph
ctx-cli mcp call find_entities -p query="authentication" -o json

# Get change confidence score for a file
ctx-cli mcp call get_change_confidence -p file_path=src/checkout/handler.ts -o json

# Free-text search across all knowledge
ctx-cli mcp call search_knowledge -p query="rate limiting strategy" -o json
```

## Discover Available Tools

```bash
# List all registered MCP tools
ctx-cli mcp list

# Get help for a specific tool
ctx-cli mcp describe investigate_service
```

## Service Investigation

Use `investigate_service` to get a complete picture of a service: its dependencies, dependents, owning team, ADRs, and recent incidents.

```bash
ctx-cli mcp call investigate_service -p service_name=order-service -o json
```

## Entity Search

Use `find_entities` to locate services, teams, flows, or ADRs by name or keyword.

```bash
ctx-cli mcp call find_entities -p query="checkout" -p entity_type=service -o json
```

## Change Confidence

Use `get_change_confidence` to assess risk before merging. Returns a confidence score, related ADRs, and hotspot data.

```bash
ctx-cli mcp call get_change_confidence -p file_path=src/payments/processor.ts -o json
```
