---
name: code-migration
description: >-
  Plan and execute code migrations — find equivalent fields, get migration
  examples.
tags:
  - migration
  - refactoring
group: composite
mcp-tools:
  - code_migration
allowed-tools: 'Bash(ctx-cli:*)'
---
# Code Migration

Plan and execute code migrations with Context Engine guidance. Find equivalent fields across schema versions and get concrete migration examples.

## Usage

```bash
# Get migration guidance for a service
ctx-cli mcp call code_migration -p service_name=payments-api -o json
```

The response includes:
- **Field mappings** — equivalent fields between old and new schemas.
- **Migration examples** — concrete before/after code samples.
- **Breaking changes** — fields removed or renamed with no direct equivalent.
- **Migration steps** — ordered checklist for the migration.

## Examples

```bash
# Find field mappings for a schema migration
ctx-cli mcp call code_migration -p service_name=order-service -p source_version=v1 -p target_version=v2 -o json

# Get migration examples
ctx-cli mcp call code_migration -p service_name=user-service -o json | jq '.migration_examples'

# List breaking changes
ctx-cli mcp call code_migration -p service_name=inventory-api -o json | jq '.breaking_changes'
```

## When to Use

- When migrating between API versions or schema versions.
- To find equivalent fields after a service refactor.
- Before a major version bump to understand the full scope of breaking changes.
