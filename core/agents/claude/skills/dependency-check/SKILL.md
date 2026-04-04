---
name: dependency-check
description: 'Check dependency health, find vulnerabilities, plan migrations.'
allowed-tools: 'Bash(ctx-cli:*)'
---
# Dependency Check

Check the health of a service's dependencies, surface known vulnerabilities, and get guidance for dependency migrations.

## Usage

```bash
# Check dependencies for a service
ctx-cli mcp call dependency_check -p service_name=payments-api --raw
```

The response includes:
- **Dependency health** — status of each upstream dependency.
- **Vulnerabilities** — known CVEs and security advisories.
- **Deprecations** — dependencies marked for removal or migration.
- **Migration guidance** — recommended replacement paths.

## Examples

```bash
# Check dependencies for user-service
ctx-cli mcp call dependency_check -p service_name=user-service --raw

# Check dependencies for order-service
ctx-cli mcp call dependency_check -p service_name=order-service --raw

# Check dependencies for legacy-gateway
ctx-cli mcp call dependency_check -p service_name=legacy-gateway --raw
```

## When to Use

- During security reviews to surface known vulnerabilities.
- Before major releases to verify dependency health.
- When planning migrations away from deprecated services or libraries.
