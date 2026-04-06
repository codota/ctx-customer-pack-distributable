---
name: onboard-baseline
description: >
  Run baseline tests — first without MCP (Step 3), then with MCP (Step 4).
  Compares results to quantify Context Engine value.
tags: [onboarding, evaluation]
---

# Onboard: Baseline Tests (Steps 3-4)

## Step 3: Without MCP
```bash
tabnine-ctx-onboard step-3 --json
```

## Step 4: With MCP
```bash
tabnine-ctx-onboard step-4 --json
```

Scores responses on relevance, depth, actionability, accuracy (0-5 each).
Compares Step 3 vs Step 4 to quantify MCP value-add.
