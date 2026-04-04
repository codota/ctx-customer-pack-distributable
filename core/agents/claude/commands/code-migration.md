Plan and execute code migrations — find equivalent fields, get migration examples.

# Code Migration

Plan and execute code migrations with Context Engine guidance. Find equivalent fields across schema versions and get concrete migration examples.

## Usage

```bash
# Get migration guidance for a service
ctx-cli mcp call code_migration -p service_name=payments-api --raw
```

The response includes:
- **Field mappings** — equivalent fields between old and new schemas.
- **Migration examples** — concrete before/after code samples.
- **Breaking changes** — fields removed or renamed with no direct equivalent.
- **Migration steps** — ordered checklist for the migration.

## Examples

```bash
# Find field mappings for a schema migration
ctx-cli mcp call code_migration -p service_name=order-service -p source_version=v1 -p target_version=v2 --raw

# Get migration guidance for user-service
ctx-cli mcp call code_migration -p service_name=user-service --raw

# Get migration guidance for inventory-api
ctx-cli mcp call code_migration -p service_name=inventory-api --raw
```

## When to Use

- When migrating between API versions or schema versions.
- To find equivalent fields after a service refactor.
- Before a major version bump to understand the full scope of breaking changes.