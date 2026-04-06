---
name: collect-logs
description: >
  Collect debug logs, checkpoints, and state into a redacted support bundle
  (tar.gz). Use when something goes wrong and the user needs to send diagnostics
  to support.
allowed-tools: mcp__tabnine-ctx-loader__loader_collect_logs
---
# Collect Support Logs

Packages all debug logs, pipeline checkpoints, and onboarding state into a single redacted tar.gz file for support.

## Usage

Call `mcp__tabnine-ctx-loader__loader_collect_logs`.

This collects:
- MCP tool execution logs from `.tabnine/ctx/logs/`
- Loader pipeline checkpoints from `.tabnine/ctx/loader/runs/`
- Onboarding state and loader output logs
- Manifest files (with secrets redacted)

The output includes the file path and size. Tell the user to email the bundle to support.

## When to use

- After a data loading failure that `tabnine-ctx-loader diagnose` can't resolve
- When onboarding steps fail unexpectedly
- When support asks for debug logs
