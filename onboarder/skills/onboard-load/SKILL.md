---
name: onboard-load
description: >
  Load project data into Context Engine using ctx-loader.
tags: [onboarding, data-loading]
---

# Onboard: Load Project (Step 2)

Loads your project data into the Context Engine.

## Prerequisite

**Before running step-2**, ensure:
1. `ctx-settings.yaml` exists with `CTX_API_URL`, `CTX_API_KEY`, `GH_PAT`, `GITHUB_ORG`, and `GITHUB_REPO`. If not, run `/onboard` to create it.
2. `ctx-loader.yaml` manifest exists. If not, generate it:
   ```bash
   ctx-loader init --template minimal --output ctx-loader.yaml
   ```
   With `ctx-settings.yaml` in place, the manifest variables resolve automatically.

## Usage

```bash
ctx-onboard step-2 --manifest ctx-loader.yaml --json
```

Wraps ctx-loader as a subprocess. Credentials loaded from `ctx-settings.yaml` or environment.

## Diagnosing failures

If agents fail during loading, use:
```bash
ctx-loader diagnose --json
```
This shows structured failure details with error codes and remediation steps.
