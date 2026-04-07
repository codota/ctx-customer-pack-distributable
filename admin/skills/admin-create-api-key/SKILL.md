---
name: admin-create-api-key
description: Create an API key for a tenant — requires admin secret and tenant ID.
tags: [admin, tenant, api-key]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Create API Key

Create an API key for an existing tenant.

## Usage

```bash
tabnine-ctx-admin create-api-key --tenant-id <id> --key-name "dev-key" --json
```

Requires `CTX_ADMIN_SECRET` in ctx-settings.yaml or environment.
