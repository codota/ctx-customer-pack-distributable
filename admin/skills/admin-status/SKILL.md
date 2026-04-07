---
name: admin-status
description: Show composite status of a Context Engine deployment — health, readiness, entity count, data sources.
tags: [admin, status]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Status

Show a composite status report for the Context Engine deployment.

## Usage

```bash
tabnine-ctx-admin status --json
```

Requires `CTX_API_KEY`. Reports health, readiness, entity count, and data source count.
