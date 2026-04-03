---
name: onboard-load
description: >
  Load project data into Context Engine using ctx-loader.
tags: [onboarding, data-loading]
---

# Onboard: Load Project (Step 2)

Loads your project data into the Context Engine.

## Usage

```bash
ctx-onboard step-2 --manifest ctx-loader.yaml --json
```

Wraps ctx-loader as a subprocess. Secrets passed via environment.
