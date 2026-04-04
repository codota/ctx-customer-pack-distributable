---
name: dependency-check
description: 'Check dependency health, find vulnerabilities, plan migrations.'
tags:
  - dependencies
  - security
group: composite
mcp-tools:
  - dependency_check
---
# Dependency Check

Check the health of a service's dependencies, surface known vulnerabilities, and get guidance for dependency migrations.

## Usage

**Check dependencies for a service**
Call `mcp__ctx-cloud__dependency_check` with service_name=payments-api.

The response includes:
- **Dependency health** — status of each upstream dependency.
- **Vulnerabilities** — known CVEs and security advisories.
- **Deprecations** — dependencies marked for removal or migration.
- **Migration guidance** — recommended replacement paths.

## Examples

**Check dependencies for user-service**
Call `mcp__ctx-cloud__dependency_check` with service_name=user-service.
**Check dependencies for order-service**
Call `mcp__ctx-cloud__dependency_check` with service_name=order-service.
**Check dependencies for legacy-gateway**
Call `mcp__ctx-cloud__dependency_check` with service_name=legacy-gateway.

## When to Use

- During security reviews to surface known vulnerabilities.
- Before major releases to verify dependency health.
- When planning migrations away from deprecated services or libraries.
