---
name: admin-ready
description: Check Context Engine readiness — detailed status of DB, Neo4j, Temporal, and workers.
tags: [admin, health, readiness]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Readiness Check

Check detailed readiness of all Context Engine subsystems.

## Usage

```bash
tabnine-ctx-admin ready --json
```

Requires API key. Reports status of PostgreSQL, Neo4j, Temporal, and worker processes.
