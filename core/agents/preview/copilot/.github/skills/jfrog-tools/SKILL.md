---
name: jfrog-tools
description: >-
  Jfrog tools: check_dependency_health, get_adoption_status,
  get_cve_blast_radius, get_migration_examples, get_migration_path,
  get_migration_status, get_package_usage_patterns, get_package_vulnerabilities,
  get_recommended_packages, get_transitive_dependents, list_all_packages,
  list_all_vulnerabilities, search_internal_packages, test_cypher_tenant,
  test_cypher_type, test_cypher
tags:
  - jfrog
  - auto-generated
group: jfrog
mcp-tools:
  - check_dependency_health
  - get_adoption_status
  - get_cve_blast_radius
  - get_migration_examples
  - get_migration_path
  - get_migration_status
  - get_package_usage_patterns
  - get_package_vulnerabilities
  - get_recommended_packages
  - get_transitive_dependents
  - list_all_packages
  - list_all_vulnerabilities
  - search_internal_packages
  - test_cypher_tenant
  - test_cypher_type
  - test_cypher
---
# Jfrog Tools

> Auto-generated from 16 exported tool(s) in the Context Engine.

## check_dependency_health

Check the security and license health of a package dependency. Returns vulnerabilities from JFrog Xray, license compliance status, blast radius (which services in your organization use this package), and migration recommendations if issues are found.
PREFER: Use 'dependency_check' for complete health assessment including upgrade history, migration examples, and recommended alternatives in one call.
USE THIS WHEN: You need just the security/license status without upgrade history context, or when checking multiple packages in a loop.

Call `mcp__tabnine-ctx-cloud__check_dependency_health` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | Package name to check. Format depends on ecosystem: - npm: "lodash" or "@scope/package" - maven: "org.apache.commons:commons-lang3" - pypi: "requests" |
| version | string | No | Specific version to check. If omitted, checks latest indexed version. |
| ecosystem | string | Yes | Package ecosystem (npm, maven, pypi) |

## get_adoption_status

Get adoption status for a recommended package or migration. Shows which services have adopted the package vs. still using old alternatives.
PREFER: Use 'code_migration' for complete migration guidance including adoption status, field mappings, migration examples, and ADR context in one call.
USE THIS WHEN: You need just the adoption percentages and service lists, or when tracking progress across multiple packages.

Call `mcp__tabnine-ctx-cloud__get_adoption_status` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | The recommended package to check adoption for (e.g., "@acme/http-client"). |

## get_cve_blast_radius

Get the complete TRANSITIVE blast radius for a CVE - which packages are directly affected and which services/packages transitively depend on them. Traverses up to 10 levels of dependency chains to find all impacted services.
Returns: - Affected packages (directly vulnerable) - Affected services with dependency chains showing how they're impacted - Team ownership and contact information - Separation of direct vs. transitive dependencies - Critical tier services highlighted
Example: If lodash has CVE-2020-8203, finds not only services using lodash directly, but also services using @acme/auth which depends on lodash.
PREFER: Use 'blast_radius' for broader impact analysis that includes affected flows, historical incidents, and complete team notifications.
USE THIS WHEN: You need just the CVE-specific blast radius without the full incident context, or when analyzing multiple CVEs systematically.

Call `mcp__tabnine-ctx-cloud__get_cve_blast_radius` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| cveId | string | Yes | CVE identifier (e.g., "CVE-2020-8203", "CVE-2021-44228"). |

## get_migration_examples

Find examples of services that have migrated from one package to another. Shows which services completed the migration, when, and by whom.
PREFER: Use 'code_migration' for complete migration guidance including field mappings, ADR context, and recommended patterns in one call.
USE THIS WHEN: You need just the list of services that completed a migration, or when tracking migration progress across the organization.

Call `mcp__tabnine-ctx-cloud__get_migration_examples` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| fromPackage | string | Yes | Package being migrated from (e.g., "log4js", "axios"). |
| toPackage | string | No | Package being migrated to (e.g., "@acme/logging", "@acme/http-client"). If omitted, shows all services that removed the fromPackage. |

## get_migration_path

Get migration guidance for upgrading or replacing a package. Shows which services depend on the package and suggests alternatives.
PREFER: Use 'code_migration' for complete migration guidance including field mappings, migration examples, ADR context, and adoption status in one call.
USE THIS WHEN: You need just the dependency graph for a package without the full migration context, or when planning migrations for multiple packages.

Call `mcp__tabnine-ctx-cloud__get_migration_path` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| fromPackage | string | Yes | Package name to migrate from (e.g., "moment" or "pac-resolver") |
| toPackage | string | No | Target package to migrate to. If omitted, shows current dependents only. |
| ecosystem | string | Yes | Package ecosystem (npm, maven, pypi) |

## get_migration_status

Get the migration status for a deprecated or replaced package. Shows which services have migrated vs. still pending, with team contacts for follow-up.
PREFER: Use 'code_migration' for complete migration guidance including field mappings, migration examples, and ADR context in one call.
USE THIS WHEN: You need just the migration progress numbers without the full migration context, or when tracking multiple migrations.

Call `mcp__tabnine-ctx-cloud__get_migration_status` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| oldPackage | string | Yes | The deprecated/old package being replaced (e.g., "log4js", "axios"). |
| newPackage | string | No | The recommended replacement package (e.g., "@acme/logging"). If omitted, will try to find from package metadata. |

## get_package_usage_patterns

Analyze how a package is used across your organization. Shows which services use the package and usage statistics. Helpful for understanding adoption and identifying usage patterns.

Call `mcp__tabnine-ctx-cloud__get_package_usage_patterns` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | Package name to analyze (e.g., "@acme/auth-sdk" or "lodash") |
| ecosystem | string | Yes | Package ecosystem (npm, maven, pypi) |

## get_package_vulnerabilities

Get all vulnerabilities linked to a package.
PREFER: Use 'dependency_check' for complete package health assessment including vulnerabilities, license status, upgrade history, and blast radius in one call.
USE THIS WHEN: You need just the vulnerability list for a specific package, or when scanning multiple packages systematically.

Call `mcp__tabnine-ctx-cloud__get_package_vulnerabilities` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | Package name pattern to search for |

## get_recommended_packages

Find recommended internal packages for a specific capability or use case. Searches for packages marked as "recommended" that match the query. Use this before adding a new dependency to see if there's an internal package you should use instead.
PREFER: Use 'dependency_check' when evaluating a specific package - includes recommended alternatives, security status, and migration guidance in one call.
USE THIS WHEN: You need to discover what internal packages exist for a capability, without evaluating a specific existing package.

Call `mcp__tabnine-ctx-cloud__get_recommended_packages` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| capability | string | Yes | What you're looking for - can be a capability (e.g., "HTTP client"), use case (e.g., "logging"), or functionality (e.g., "authentication"). |
| ecosystem | string | No | Filter by package ecosystem: "npm", "maven", "pypi", "go". Leave empty to search all ecosystems. |

## get_transitive_dependents

Get all services and packages that depend on a package, including transitive dependencies. Shows which services would need to be rebuilt or tested if this package changes.
PREFER: Use 'blast_radius' for complete impact analysis including affected flows, teams to notify, and historical incidents in one call.
USE THIS WHEN: You need just the dependency tree without the broader impact context, or when analyzing package-level dependencies only.

Call `mcp__tabnine-ctx-cloud__get_transitive_dependents` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | Package name to find dependents for (e.g., "@acme/logging" or "lodash"). Supports partial matching. |
| maxDepth | number | No | Maximum depth to traverse for transitive dependencies. Default is 5. Use 1 for direct dependents only. |
| includePackages | boolean | No | Include package-to-package dependencies in results. Default is true. Set to false to only show services. |

## list_all_packages

Diagnostic tool: List all Package entities in the knowledge graph. Returns all indexed packages to verify entity creation worked.

Call `mcp__tabnine-ctx-cloud__list_all_packages` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| limit | number | No | Maximum number of results (default 100) |

## list_all_vulnerabilities

Diagnostic tool: List all Vulnerability entities in the knowledge graph. Returns all indexed vulnerabilities to verify entity creation worked.

Call `mcp__tabnine-ctx-cloud__list_all_vulnerabilities` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| limit | number | No | Maximum number of results (default 100) |

## search_internal_packages

Search for internal packages in JFrog Artifactory using semantic matching. Finds packages by name, description, or functionality, and enriches results with usage statistics (how many services use each package) and security data. Use this to discover internal libraries before implementing new functionality.

Call `mcp__tabnine-ctx-cloud__search_internal_packages` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query - describe what you're looking for (package name, functionality, or natural language description like "http client with retry" or "logging library") |
| ecosystem | string | No | Filter by package ecosystem (npm, maven, pypi). Leave empty to search all. |
| limit | number | No | Maximum number of results to return (default 10, max 50) |

## test_cypher_tenant

Test Cypher with tenantId

Call `mcp__tabnine-ctx-cloud__test_cypher_tenant` with parameters:

## test_cypher_type

Test Cypher with type filter

Call `mcp__tabnine-ctx-cloud__test_cypher_type` with parameters:

## test_cypher

Simple test of Cypher query execution

Call `mcp__tabnine-ctx-cloud__test_cypher` with parameters:
