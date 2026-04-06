Search the knowledge graph for entities, documentation, and patterns.

# Search Knowledge

Search across the full Context Engine knowledge graph for services, teams, ADRs, documentation, and architectural patterns.

## Usage

```bash
# Free-text search across all knowledge
tabnine-ctx-loader query search "rate limiting"

# Find specific entity types
tabnine-ctx-loader query entities --type service --search "checkout"

# Search with field selection (returns only the specified fields)
tabnine-ctx-loader query search "checkout" --fields entityType,entityName,similarity
```

## search

Performs a semantic search across all indexed knowledge: ADRs, runbooks, documentation, and incident postmortems.

```bash
# Search for documentation on a topic
tabnine-ctx-loader query search "database sharding strategy"

# Find patterns and best practices
tabnine-ctx-loader query search "retry backoff pattern"

# Limit results and select fields
tabnine-ctx-loader query search "caching" --limit 5 --fields entityType,entityName
```

## entities

Locates specific entities in the knowledge graph by name, type, or keyword.

```bash
# Find all services matching a keyword
tabnine-ctx-loader query entities --type service --search "payment"

# Find teams
tabnine-ctx-loader query entities --type team --search "platform"

# List all entities of a type
tabnine-ctx-loader query entities --type adr --limit 50
```

## When to Use

- To discover existing documentation before writing new docs.
- To find services, teams, or ADRs by keyword.
- To locate architectural patterns and best practices in your organization.