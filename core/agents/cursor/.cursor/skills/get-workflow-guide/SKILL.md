---
name: get-workflow-guide
description: >-
  Get workflow guides for using Context Engine tools effectively. Call this at
  the start of a session to understand which tools to use for common workflows
  like investigating services, responding to incidents, assessing blast radius,
  managing dependencies, and exploring architecture. Returns a comprehensive
  guide covering all major workflows with step-by-step instructions.
tags:
  - workflow-guides
  - auto-generated
group: workflow-guides
mcp-tools:
  - get_workflow_guide
---
# Workflow guides Tools

> Auto-generated from 1 exported tool(s) in the Context Engine.

## get_workflow_guide

Get workflow guides for using Context Engine tools effectively. Call this at the start of a session to understand which tools to use for common workflows like investigating services, responding to incidents, assessing blast radius, managing dependencies, and exploring architecture. Returns a comprehensive guide covering all major workflows with step-by-step instructions.

Call `mcp__tabnine-ctx-cloud__get_workflow_guide` with parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| workflow | string | No | Optional filter to a specific workflow: "investigate", "incident", "dependency", "architecture", "blast-radius", "search". If omitted, returns all workflow guides. |
