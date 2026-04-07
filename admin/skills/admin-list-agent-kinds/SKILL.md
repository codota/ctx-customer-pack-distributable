---
name: admin-list-agent-kinds
description: List all available agent kinds in the Context Engine.
tags: [admin, agents]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: List Agent Kinds

List all agent kinds registered in the Context Engine.

## Usage

```bash
tabnine-ctx-admin list-agent-kinds --json
```

Requires `CTX_API_KEY` in ctx-settings.yaml or environment.
