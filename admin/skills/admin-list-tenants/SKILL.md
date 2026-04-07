---
name: admin-list-tenants
description: List all tenants in the Context Engine — requires admin secret.
tags: [admin, tenant]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: List Tenants

List all tenants registered in the Context Engine.

## Usage

```bash
tabnine-ctx-admin list-tenants --json
```

Requires `CTX_ADMIN_SECRET` in ctx-settings.yaml or environment.
