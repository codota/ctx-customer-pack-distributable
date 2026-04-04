---
name: decision-context-tools
description: >-
  Decision context tools: create_code_module, get_file_context,
  list_code_modules, resolve_file_to_service
tags:
  - decision-context
  - auto-generated
group: decision-context
mcp-tools:
  - create_code_module
  - get_file_context
  - list_code_modules
  - resolve_file_to_service
---
# Decision context Tools

> Auto-generated from 4 exported tool(s) in the Context Engine.

## create_code_module

Register a CodeModule mapping file patterns to a service or package.
CodeModules bridge file paths to architectural entities. When a developer edits a file matching a module's patterns, the system can surface relevant ADRs, incidents, and context.
Example: Create a module for payment processing code: create_code_module(
  name="payment-processor",
  filePatterns=["src/payment/**", "lib/payment-utils/**"],
  service="payment-service",
  criticality="critical",
  tags=["pci-compliant", "financial"]
)
NOTE: This tool creates the entity. For bulk import, use the code-module-discovery agent.

Call `mcp__ctx-cloud__create_code_module` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | Yes | Unique name for the code module (e.g., "payment-processor", "auth-middleware"). Use lowercase with hyphens. |
| description | string | Yes | Brief description of what this module contains and its purpose. |
| filePatterns | array | Yes | Glob patterns that match files belonging to this module. Examples: ["src/payment/**"], ["packages/auth/src/**", "packages/auth/lib/**"] |
| service | string | No | Name of the Service entity this module belongs to. Must match an existing Service entity name. |
| package | string | No | Name of the Package entity this module belongs to (for internal packages). Use either service OR package, not both. |
| technology | string | No | Primary technology/language: "typescript", "go", "java", "python", etc. |
| criticality | string | No | Criticality level: "critical", "high", "medium", "low". Affects how prominently context is surfaced. Default: "medium". |
| tags | array | No | Tags for categorization and pattern matching. Examples: ["pci-compliant", "user-facing", "background-job"] |
| repository | string | No | Repository this module belongs to (for multi-repo setups). |

## get_file_context

Get decision context for a file path - the key tool for "Decision Context at Point of Coding".
Given a file path being edited, returns all relevant architectural context: - The CodeModule and Service the file belongs to - ADRs that apply to this service/module - Recent incidents that affected this area - Security patterns relevant to this code - Code experts who know this file best - Blast radius (what depends on this service) - Related runbooks for operational context
Results are scored by relevance and recency.
USE THIS WHEN: A developer or agent is about to modify a file and needs to understand the architectural context, past issues, and potential impact before making changes.
Example: get_file_context(filepath="src/payment/processor.ts") Returns: ADRs about payment idempotency, past payment incidents, PCI security patterns, experts on the payment module, services that depend on payment-service.

Call `mcp__ctx-cloud__get_file_context` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| filepath | string | Yes | The file path being edited (relative to repository root). Examples: "src/payment/processor.ts", "packages/auth/src/index.ts" |
| repository | string | No | Repository name to scope the search. If omitted, searches across all repositories. |
| includeBlastRadius | boolean | No | Include blast radius analysis (services that depend on this one). Default: true. Set to false for faster response when impact analysis isn't needed. |
| incidentLookbackDays | number | No | How many days back to look for relevant incidents. Default: 180 (6 months). |

## list_code_modules

List all CodeModule entities, optionally filtered by service or repository.
Shows file pattern mappings that enable decision context lookup.

Call `mcp__ctx-cloud__list_code_modules` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| service | string | No | Filter to modules belonging to a specific service. |
| repository | string | No | Filter to modules in a specific repository. |
| limit | number | No | Maximum number of modules to return. Default: 50. |

## resolve_file_to_service

Quick lookup: resolve a file path to its owning service.
Lighter-weight than get_file_context - just returns the service mapping without all the decision context. Use this for fast service identification.
Falls back to heuristics if no CodeModule matches: 1. Checks if path contains a known service name 2. Looks for service.json/package.json in parent directories 3. Uses repository name as fallback

Call `mcp__ctx-cloud__resolve_file_to_service` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| filepath | string | Yes | File path to resolve (relative to repository root). |
| repository | string | No | Repository name for disambiguation in multi-repo setups. |
