---
name: admin-deploy-azure
description: Deploy Context Engine to Azure AKS — PLACEHOLDER, not yet automated. References manual deployment guide.
tags: [admin, deploy, azure, placeholder]
group: admin
allowed-tools: Bash(tabnine-ctx-admin:*)
---

# Admin: Deploy to Azure (Placeholder)

This command is not yet automated. It will handle the full Azure AKS deployment lifecycle.

## Manual Deployment Guide

Follow the step-by-step guide in your CTX repository at `.claude/commands/deploy-azure.md`:

- Phase 0: Preflight (az, helm, kubectl, docker validation)
- Phase 1: Azure infrastructure (resource group, VNet, Key Vault, ACR, PostgreSQL, Redis)
- Phase 2: AKS cluster creation
- Phase 3: Platform components (ingress-nginx, cert-manager, ESO)
- Phase 4: In-cluster infrastructure (PostgreSQL, Neo4j, Temporal, ClickHouse, OpenFGA)
- Phase 5: Build and push Docker images
- Phase 6: Deploy CTX via Helm
- Phase 7-8: Verification and smoke testing

## When This Will Be Implemented

This command requires cloud provider SDK integration, Kubernetes client library, and Helm chart management capabilities.
