Semantic concepts tools: find_equivalent_fields, get_concept_implementations, get_domain_concepts, list_semantic_domains, search_concepts

# Semantic concepts Tools

> Auto-generated from 5 exported tool(s) in the Context Engine.

## find_equivalent_fields

Find equivalent fields across repositories for a given field name. Given a field like "windowMs" from one repo, finds semantically equivalent fields in other repos (e.g., "timeWindow", "duration", "Period").
PREFER: Use 'code_migration' for complete migration guidance including field mappings, migration examples, and ADR context in one call.
USE THIS WHEN: You need just the field equivalents without the full migration context, or when exploring semantic patterns across repos.

Call `mcp__tabnine-ctx-cloud__find_equivalent_fields` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| fieldName | string | Yes | Field name to find equivalents for (e.g., "windowMs", "maxRetries", "timeout"). |
| sourceRepository | string | No | Repository the field comes from (helps narrow down the concept). |
| limit | number | No | Maximum number of equivalent fields to return (default 15). |

## get_concept_implementations

Get all implementations of a semantic concept across repositories. Shows how the same abstract concept is implemented with different field names, types, and interfaces in different codebases. Use this for migration guidance or to understand cross-repo field equivalents.

Call `mcp__tabnine-ctx-cloud__get_concept_implementations` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| concept | string | Yes | Concept name to get implementations for (e.g., "time-window", "max-requests"). Supports partial matching. |
| repository | string | No | Filter to implementations in a specific repository. |
| language | string | No | Filter by programming language (e.g., "typescript", "go", "java"). |
| limit | number | No | Maximum number of implementations to return (default 20). |

## get_domain_concepts

Get all semantic concepts within a domain. Shows concepts with their descriptions, implementation counts, and the various names used across different repositories. Use this to understand what abstractions exist within a domain like "rate-limiting" or "authentication".

Call `mcp__tabnine-ctx-cloud__get_domain_concepts` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| domain | string | Yes | Domain name to get concepts for (e.g., "rate-limiting", "authentication"). Supports partial matching. |
| limit | number | No | Maximum number of concepts to return (default 30). |

## list_semantic_domains

List all semantic domains discovered across repositories. Domains are high-level categories of related functionality (e.g., "rate-limiting", "authentication", "caching"). Use this to understand what cross-cutting concepts exist in your codebase.

Call `mcp__tabnine-ctx-cloud__list_semantic_domains` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| minConceptCount | number | No | Minimum number of concepts a domain must have to be included. Default is 1. |
| minRepositoryCount | number | No | Minimum number of repositories implementing the domain. Default is 1. |
| limit | number | No | Maximum number of domains to return (default 20). |

## search_concepts

Search for semantic concepts across all domains by keyword. Finds concepts by name, description, or alternate names used in different repos. Use this to find cross-repo equivalents for a field or configuration option.

Call `mcp__tabnine-ctx-cloud__search_concepts` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | Search query - can be a concept name (e.g., "timeout"), field name (e.g., "windowMs"), or description keyword (e.g., "rate limit duration"). |
| limit | number | No | Maximum number of concepts to return (default 15). |