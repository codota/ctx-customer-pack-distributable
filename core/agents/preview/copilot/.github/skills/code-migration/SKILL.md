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
---
# Code Migration

Plan and execute code migrations with Context Engine guidance. Find equivalent fields across schema versions and get concrete migration examples.

## Usage

**Get migration guidance for a service**
Call `mcp__tabnine-ctx-cloud__code_migration` with service_name=payments-api.

The response includes:
- **Field mappings** — equivalent fields between old and new schemas.
- **Migration examples** — concrete before/after code samples.
- **Breaking changes** — fields removed or renamed with no direct equivalent.
- **Migration steps** — ordered checklist for the migration.

## Examples

**Find field mappings for a schema migration**
Call `mcp__tabnine-ctx-cloud__code_migration` with service_name=order-service, source_version=v1, target_version=v2.
**Get migration guidance for user-service**
Call `mcp__tabnine-ctx-cloud__code_migration` with service_name=user-service.
**Get migration guidance for inventory-api**
Call `mcp__tabnine-ctx-cloud__code_migration` with service_name=inventory-api.

## When to Use

- When migrating between API versions or schema versions.
- To find equivalent fields after a service refactor.
- Before a major version bump to understand the full scope of breaking changes.
