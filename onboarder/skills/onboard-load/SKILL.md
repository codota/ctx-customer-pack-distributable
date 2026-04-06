---
name: onboard-load
description: >
  Load project data into Context Engine using tabnine-ctx-loader.
tags: [onboarding, data-loading]
---

# Onboard: Load Project (Step 2)

Loads your project data into the Context Engine.

## Prerequisite

**Before running step-2**, ensure:
1. `.tabnine/ctx/ctx-settings.yaml` exists with `CTX_API_URL`, `CTX_API_KEY`, `GH_PAT`, `GITHUB_ORG`, and `GITHUB_REPO`. If not, run `/onboard` to create it.
2. `tabnine-ctx-loader.yaml` manifest exists. If not, generate it:
   ```bash
   tabnine-ctx-loader init --template minimal --output tabnine-ctx-loader.yaml
   ```
   With `.tabnine/ctx/ctx-settings.yaml` in place, the manifest variables resolve automatically.

## Usage

```bash
tabnine-ctx-onboard step-2 --manifest tabnine-ctx-loader.yaml --json
```

Wraps tabnine-ctx-loader as a subprocess. Credentials loaded from `.tabnine/ctx/ctx-settings.yaml` or environment.

## Diagnosing failures

If agents fail during loading, use:
```bash
tabnine-ctx-loader diagnose --json
```
This shows structured failure details with error codes and remediation steps.
