---
name: graph-tools-tools
description: 'Graph tools tools: find_entities, get_entity_by_id, traverse_edges'
allowed-tools: >-
  mcp__ctx-cloud__find_entities, mcp__ctx-cloud__get_entity_by_id,
  mcp__ctx-cloud__traverse_edges
---
# Graph tools Tools

> Auto-generated from 3 exported tool(s) in the Context Engine.

## find_entities

Find entities in the knowledge graph using semantic search. Use this as your starting point for graph exploration - it understands natural language queries and finds semantically similar content even without exact keyword matches.
Search strategies: - Natural language: "authentication services" finds auth-related entities - Conceptual: "security vulnerabilities" finds security findings - Filtered: Set entityTypes to narrow results (e.g., ["Service", "CodePattern"])
Common entity types: Service, CodePattern, Finding, CodeExpert, CodeHotspot, CodeCoupling, Feature, ModuleBoundary, Package, Vulnerability
Returns entity ID, type, name, data, and similarity score. Use returned IDs with traverse_edges to explore relationships or get_entity_by_id for details.

Call `mcp__ctx-cloud__find_entities` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Natural language search query describing what you're looking for |
| entityTypes | array | No | Filter to specific entity types (e.g., ["Service", "CodePattern"]) |
| limit | number | No | Maximum number of results to return (default 10) |
| minSimilarity | number | No | Minimum similarity threshold 0-1 (default 0.5) |

## get_entity_by_id

Get full details of a specific entity by its ID. Use this when you already have an entity ID (e.g., from find_entities or traverse_edges results) and need to see its complete data.
Returns: id, name, type, data (JSON properties), createdAt, createdBy

Call `mcp__ctx-cloud__get_entity_by_id` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| entityId | string | Yes | The entity ID to retrieve |

## traverse_edges

Traverse edges from an entity to discover related entities. Use this after find_entities to explore the graph structure and relationships.
Direction controls which edges to follow: - "out": Edges where this entity is the source (this -> related) - "in": Edges where this entity is the target (related -> this) - "both": Edges in either direction (default)
Common edge types: depends_on, calls, contains, manages, created_together, references, produces, consumes
Example workflow: 1. find_entities(query="payment service") -> get service ID 2. traverse_edges(entityId="...", direction="out") -> what does it depend on? 3. traverse_edges(entityId="...", direction="in") -> what depends on it? 4. traverse_edges(entityId="...", edgeType="calls") -> what does it call?
For multi-hop traversal, call this tool repeatedly with the returned entity IDs.

Call `mcp__ctx-cloud__traverse_edges` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| entityId | string | Yes | The ID of the entity to start traversal from |
| edgeType | string | No | Filter by relationship type (e.g., "depends_on", "calls", "contains") |
| direction | string | No | Direction to traverse - "in", "out", or "both" (default "both") |
| limit | number | No | Maximum number of related entities to return (default 25) |
