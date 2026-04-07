---
name: admin-configure-ai
description: Configure the LLM provider (e.g. Anthropic) for a Context Engine tenant.
tags: [admin, configuration, ai]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Configure AI Provider

Configure the LLM provider for agent execution.

## Usage

```bash
tabnine-ctx-admin configure-ai --provider anthropic_direct --json
```

Requires `CTX_API_KEY` and the provider's API key as an environment variable (e.g. `ANTHROPIC_API_KEY`). Never pass API keys as CLI arguments.

Supported providers: `anthropic_direct`, `openai`, `azure_openai`.
