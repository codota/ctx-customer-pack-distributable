---
name: onboard-measure
description: >
  Re-run tests with domain enrichment active. Produces 3-way comparison
  against all baselines.
tags: [onboarding, evaluation]
---

# Onboard: Measure with Domain (Step 6)

```bash
tabnine-ctx-onboard step-6 --json
```

Compares: no-MCP vs with-MCP vs with-domain.
Only compares answer-quality metrics across all modes (tool usage only between MCP modes).
