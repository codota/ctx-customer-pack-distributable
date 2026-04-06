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
---
# Review PR

Review pull requests with full architectural context from the Context Engine. Surface risk scores, relevant ADRs, code hotspots, and ownership information.

## Assess Change Confidence

Get a risk score for changed files. Higher confidence means lower risk.

**Check confidence for a specific file**
Call `mcp__tabnine-ctx-cloud__get_change_confidence` with file_path=src/payments/processor.ts.
**Check confidence for another changed file**
Call `mcp__tabnine-ctx-cloud__get_change_confidence` with file_path=src/checkout/cart.ts.

## Get File Context

Retrieve architectural context for a file: which service it belongs to, relevant ADRs, and whether it is a hotspot.

Call `mcp__tabnine-ctx-cloud__get_file_context` with file_path=src/payments/processor.ts.

## Check Blast Radius

If the PR modifies a service, check what downstream services and flows are affected.

Call `mcp__tabnine-ctx-cloud__blast_radius` with service_name=payments-api.

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
