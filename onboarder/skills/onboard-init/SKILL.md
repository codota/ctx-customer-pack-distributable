---
name: onboard-init
description: >
  Initialize Context Engine onboarding — validates connectivity, detects
  server capabilities, checks prerequisites.
tags: [onboarding, setup]
---

# Onboard: Initialize (Step 0)

Validates your Context Engine setup and detects server capabilities.

## Prerequisite

**Before running step-0**, ensure `.tabnine/ctx/ctx-settings.yaml` exists in the current directory with at least `CTX_API_URL` and `CTX_API_KEY`. If it doesn't exist, run `/onboard` to create it, or create it manually.

## Usage

```bash
tabnine-ctx-onboard step-0 --json
```

Reads CTX_API_URL and CTX_API_KEY from `.tabnine/ctx/ctx-settings.yaml` or environment variables.

## What it checks

- CTX API reachability and authentication
- Server capabilities (credential types, extension install, agent kinds)
- Network connectivity (proxy, CA certs if configured)

## Next step

After initialization, build your testing lab:
```bash
tabnine-ctx-onboard step-1 --repo-path /path/to/repo --json
```
