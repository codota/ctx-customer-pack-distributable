---
name: admin-health
description: Check Context Engine server health — basic liveness probe, no authentication required.
tags: [admin, health]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Health Check

Check if the Context Engine server is reachable and responding.

## Usage

```bash
tabnine-ctx-admin health --api-url https://ctx.example.com --json
```

No authentication required. Returns server health status.
