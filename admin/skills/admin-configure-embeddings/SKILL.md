---
name: admin-configure-embeddings
description: Configure the embedding model (e.g. OpenAI text-embedding-3-small) for a Context Engine tenant.
tags: [admin, configuration, embeddings]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Configure Embedding Model

Configure the embedding model used for semantic search and entity matching.

## Usage

```bash
tabnine-ctx-admin configure-embeddings --provider openai --model text-embedding-3-small --dimensions 1536 --json
```

Requires `CTX_API_KEY` and the provider's API key as an environment variable (e.g. `OPENAI_API_KEY`). Never pass API keys as CLI arguments.
