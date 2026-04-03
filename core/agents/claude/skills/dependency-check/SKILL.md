---
name: dependency-check
description: 'Check dependency health, find vulnerabilities, plan migrations.'
tags:
  - dependencies
  - security
group: composite
mcp-tools:
  - dependency_check
allowed-tools: 'Bash(ctx-cli:*)'
---
# Dependency Check

Check the health of a service's dependencies, surface known vulnerabilities, and get guidance for dependency migrations.

## Usage

```bash
# Check dependencies for a service
ctx-cli mcp call dependency_check -p service_name=payments-api -o json
```

The response includes:
- **Dependency health** — status of each upstream dependency.
- **Vulnerabilities** — known CVEs and security advisories.
- **Deprecations** — dependencies marked for removal or migration.
- **Migration guidance** — recommended replacement paths.

## Examples

```bash
# List all unhealthy dependencies
ctx-cli mcp call dependency_check -p service_name=user-service -o json | jq '.vulnerabilities'

# Check for deprecated dependencies
ctx-cli mcp call dependency_check -p service_name=order-service -o json | jq '.deprecations'

# Get migration guidance for a specific service
ctx-cli mcp call dependency_check -p service_name=legacy-gateway -o json | jq '.migration_guidance'
```

## When to Use

- During security reviews to surface known vulnerabilities.
- Before major releases to verify dependency health.
- When planning migrations away from deprecated services or libraries.
