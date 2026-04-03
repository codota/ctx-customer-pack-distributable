Composite skills tools: blast_radius, code_migration, dependency_check, incident_response, investigate_service, understand_flow

# Composite skills Tools

> Auto-generated from 6 exported tool(s) in the Context Engine.

## blast_radius

Analyze the full impact of changes to a service or package. Shows all dependents (direct and transitive), affected business flows, teams to notify, and historical incidents caused by similar changes. Use BEFORE making changes to understand the risk.
This composite skill replaces the need to call: get-transitive-dependents, get-service-flows, get-service-dependents, and get-team-services individually.

```bash
ctx-cli mcp call blast_radius -p target=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| target | string | Yes | Service or package name to analyze (e.g., "auth-service", "@acme/logging", "payment-api"). Supports partial matching. |
| changeType | string | No | Type of change being planned: "breaking", "deprecation", "upgrade", "refactor", "feature". Helps prioritize risk assessment. |

## code_migration

Complete migration guidance for moving from one package/pattern to another. Shows current migration status, examples from teams that have completed it, equivalent field mappings, and services still pending migration. Use when planning or executing a migration.
This composite skill replaces the need to call: get-migration-status, get-migration-examples, find-equivalent-fields, get-adoption-status, and get-transitive-dependents individually.

```bash
ctx-cli mcp call code_migration -p fromPackage=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| fromPackage | string | Yes | Package or pattern to migrate FROM (e.g., "moment", "axios", "log4js", "@old/auth"). Supports partial matching. |
| toPackage | string | No | Package or pattern to migrate TO (e.g., "date-fns", "@acme/http-client", "@acme/logging"). If omitted, will suggest alternatives. |

## dependency_check

Complete health check for a package dependency. Shows vulnerabilities, upgrade history (did past upgrades require code changes?), migration examples from other teams, and recommended internal alternatives. Use BEFORE adding or upgrading any dependency.
This composite skill replaces the need to call: check-dependency-health, get-package-upgrade-history, get-migration-examples, get-recommended-packages, and get-package-vulnerabilities individually.

```bash
ctx-cli mcp call dependency_check -p packageName=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| packageName | string | Yes | Package name to check (e.g., "lodash", "@acme/http-client", "axios", "moment"). Supports partial matching. |
| ecosystem | string | No | Package ecosystem: "npm", "maven", "pypi", "go". Leave empty to search all ecosystems. |

## incident_response

Everything you need during an incident: escalation contacts, runbooks, similar past incidents with their root causes, and service ownership. Use this IMMEDIATELY when there's a production issue or incident.
This composite skill replaces the need to call: get-incident-contacts, get-runbook, search-incidents, get-service-ownership, and get-security-patterns individually.

```bash
ctx-cli mcp call incident_response -p service=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| service | string | Yes | Service or feature experiencing the issue (e.g., "checkout", "payment-service", "order-api"). Supports partial matching. |
| symptom | string | No | Description of the issue/symptom (e.g., "5xx errors", "high latency", "connection timeouts"). Used to find similar past incidents. |

## investigate_service

Comprehensive service investigation that returns everything you need to understand a service: its details, dependencies, dependents, ownership, documentation, business flows, active Jira issues, and GitLab issues. Use this as your FIRST tool when investigating, debugging, or understanding any service.
This composite skill replaces the need to call: get-service, get-service-dependencies, get-service-dependents, get-service-ownership, get-service-documentation, get-service-flows, and search_gitlab_issues individually.

```bash
ctx-cli mcp call investigate_service -p serviceName=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| serviceName | string | Yes | Service name to investigate (e.g., "order-service", "payment-api"). Supports partial matching. |

## understand_flow

Deep dive into a business flow or process. Shows the complete step-by-step flow, all services involved with their roles, related architectural decisions, past incidents, and operational runbooks. Use this to understand how a feature or business process works end-to-end.
This composite skill replaces the need to call: get-flow, get-flow-services, search-adrs, search-incidents, and get-runbook individually.

```bash
ctx-cli mcp call understand_flow -p flowName=<string> -o json
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| flowName | string | Yes | Flow or process name (e.g., "checkout", "payment-processing", "order-fulfillment", "user-registration"). Supports partial matching. |