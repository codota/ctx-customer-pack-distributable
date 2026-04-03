---
name: review-pr
description: >-
  Review pull requests with architectural context — risk scores, ADRs, hotspots,
  ownership.
tags:
  - code-review
  - risk
group: composite
mcp-tools:
  - get_change_confidence
  - get_file_context
  - blast_radius
allowed-tools: 'Bash(ctx-cli:*)'
---
# Review PR

Review pull requests with full architectural context from the Context Engine. Surface risk scores, relevant ADRs, code hotspots, and ownership information.

## Assess Change Confidence

Get a risk score for changed files. Higher confidence means lower risk.

```bash
# Check confidence for a specific file
ctx-cli mcp call get_change_confidence -p file_path=src/payments/processor.ts -o json

# Check confidence for another changed file
ctx-cli mcp call get_change_confidence -p file_path=src/checkout/cart.ts -o json
```

## Get File Context

Retrieve architectural context for a file: which service it belongs to, relevant ADRs, and whether it is a hotspot.

```bash
ctx-cli mcp call get_file_context -p file_path=src/payments/processor.ts -o json
```

## Check Blast Radius

If the PR modifies a service, check what downstream services and flows are affected.

```bash
ctx-cli mcp call blast_radius -p service_name=payments-api -o json
```

## Recommended Review Workflow

1. List changed files in the PR.
2. Run `get_change_confidence` on each changed file to identify high-risk areas.
3. Run `get_file_context` on high-risk files to find relevant ADRs and ownership.
4. Run `blast_radius` on affected services to understand downstream impact.
5. Focus review effort on files with low confidence scores and high blast radius.

## When to Use

- During code review to prioritize where to focus attention.
- Before approving changes to critical services.
- To surface relevant ADRs that reviewers should be aware of.
