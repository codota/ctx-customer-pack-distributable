---
name: search-knowledge
description: 'Search the knowledge graph for entities, documentation, and patterns.'
tags:
  - search
  - knowledge-graph
group: core
mcp-tools:
  - search_knowledge
  - find_entities
---
# Search Knowledge

Search across the full Context Engine knowledge graph for services, teams, ADRs, documentation, and architectural patterns.

## Usage

```bash
# Free-text search across all knowledge
ctx-cli mcp call search_knowledge -p query="rate limiting" -o json

# Find specific entity types
ctx-cli mcp call find_entities -p query="checkout" -p entity_type=service -o json
```

## search_knowledge

Performs a semantic search across all indexed knowledge: ADRs, runbooks, documentation, and incident postmortems.

```bash
# Search for documentation on a topic
ctx-cli mcp call search_knowledge -p query="database sharding strategy" -o json

# Find patterns and best practices
ctx-cli mcp call search_knowledge -p query="retry backoff pattern" -o json
```

## find_entities

Locates specific entities in the knowledge graph by name, type, or keyword.

```bash
# Find all services matching a keyword
ctx-cli mcp call find_entities -p query="payment" -p entity_type=service -o json

# Find teams
ctx-cli mcp call find_entities -p query="platform" -p entity_type=team -o json

# Find ADRs related to a topic
ctx-cli mcp call find_entities -p query="event sourcing" -p entity_type=adr -o json
```

## When to Use

- To discover existing documentation before writing new docs.
- To find services, teams, or ADRs by keyword.
- To locate architectural patterns and best practices in your organization.
