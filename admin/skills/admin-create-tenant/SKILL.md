---
name: admin-create-tenant
description: Create a new tenant in the Context Engine — requires admin secret.
tags: [admin, tenant]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Create Tenant

Create a new tenant for an organization.

## Usage

```bash
tabnine-ctx-admin create-tenant --name "my-org" --slug "my-org" --json
```

Requires `CTX_ADMIN_SECRET` in ctx-settings.yaml or environment.
