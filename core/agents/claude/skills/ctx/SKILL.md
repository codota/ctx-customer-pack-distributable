---
name: ctx
description: >-
  Query the Context Engine knowledge graph — investigate services, check blast
  radius, search entities, manage issues, and assess change risk.
allowed-tools: >-
  mcp__tabnine-ctx-cloud__investigate_service,
  mcp__tabnine-ctx-cloud__blast_radius, mcp__tabnine-ctx-cloud__find_entities,
  mcp__tabnine-ctx-cloud__get_change_confidence,
  mcp__tabnine-ctx-cloud__search_knowledge
---
# Context Engine (ctx)

## Prerequisites

1. Ensure the Context Engine MCP server (`tabnine-ctx-cloud`) is configured.
2. Set the `CTX_API_KEY` and `CTX_API_URL` environment variables.
3. Verify connectivity by calling `mcp__tabnine-ctx-cloud__search_knowledge` with query="hello".

## Quick Start

- **Search for any entity**: Call `mcp__tabnine-ctx-cloud__find_entities` with query="authentication".
- **Investigate a service**: Call `mcp__tabnine-ctx-cloud__investigate_service` with serviceName=payments-api.
- **Check blast radius**: Call `mcp__tabnine-ctx-cloud__blast_radius` with target=payments-api.
- **Get change confidence**: Call `mcp__tabnine-ctx-cloud__get_change_confidence` with files=["src/checkout/handler.ts"].
- **Search knowledge**: Call `mcp__tabnine-ctx-cloud__search_knowledge` with query="rate limiting strategy".

## Composite Tools

For aggregated investigations that combine multiple queries server-side:

- **Service investigation** (dependencies, ownership, incidents): Call `mcp__tabnine-ctx-cloud__investigate_service` with serviceName=order-service.
- **Change confidence score**: Call `mcp__tabnine-ctx-cloud__get_change_confidence` with files=["src/payments/processor.ts"].
