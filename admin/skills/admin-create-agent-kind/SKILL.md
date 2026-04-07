---
name: admin-create-agent-kind
description: Create a new agent kind in the Context Engine — define name, role, and system prompt.
tags: [admin, agents]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Create Agent Kind

Create a new agent kind (type) for use in agent runs.

## Usage

```bash
tabnine-ctx-admin create-agent-kind --name "my-agent" --description "Custom agent" --role "investigator" --prompt "You are an expert..." --json
```

Requires `CTX_API_KEY` in ctx-settings.yaml or environment.
