---
name: onboard-domain
description: >
  Domain enrichment — analyzes your repository for domain concepts,
  builds a domain model, and loads it into the Context Engine.
tags: [onboarding, domain]
---

# Onboard: Domain Enrichment (Step 5)

## Usage

```bash
tabnine-ctx-onboard step-5 --repo-path /path/to/repo --json
```

Capability-gated: uses full ontology mode if extension install is available,
falls back to guideline-only mode otherwise.
