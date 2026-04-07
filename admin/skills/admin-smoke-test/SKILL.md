---
name: admin-smoke-test
description: Run a full smoke test against a Context Engine deployment — creates test tenant, configures AI, ingests data, verifies knowledge graph and MCP tools.
tags: [admin, testing, smoke-test]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Smoke Test

Run a comprehensive multi-phase verification of a Context Engine deployment.

## Phases

1. API Health check
2. Create test tenant
3. Create API key
4. Readiness check
5. Configure AI provider (if `ANTHROPIC_API_KEY` set)
6. Configure embeddings (if `OPENAI_API_KEY` set)
7. Data ingestion (test repo)
8. Entity query verification
9. Search verification
10. MCP tools verification
11. Cleanup

## Usage

```bash
tabnine-ctx-admin smoke-test --json
tabnine-ctx-admin smoke-test --tenant-name "my-test" --skip-cleanup --json
```

Requires `CTX_ADMIN_SECRET`. Optionally set `ANTHROPIC_API_KEY` and `OPENAI_API_KEY` for full coverage.
