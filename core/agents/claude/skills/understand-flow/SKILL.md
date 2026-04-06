---
name: understand-flow
description: 'Understand a business flow end-to-end — services involved, ADRs, incidents.'
allowed-tools: mcp__tabnine-ctx-cloud__understand_flow
---
# Understand Flow

Trace a business flow end-to-end through the service graph. See every service involved, relevant ADRs, and incidents that have affected the flow.

## Usage

**Understand a business flow**
Call `mcp__tabnine-ctx-cloud__understand_flow` with flow_name=checkout.

The response includes:
- **Services** — ordered list of services the flow traverses.
- **ADRs** — architecture decision records relevant to the flow.
- **Incidents** — past incidents that affected this flow.
- **SLOs** — service-level objectives defined for the flow.

## Examples

**Trace the full checkout flow**
Call `mcp__tabnine-ctx-cloud__understand_flow` with flow_name=checkout.
**Understand the payment processing flow**
Call `mcp__tabnine-ctx-cloud__understand_flow` with flow_name=payment-processing.
**Understand the user registration flow**
Call `mcp__tabnine-ctx-cloud__understand_flow` with flow_name=user-registration.

## When to Use

- When onboarding to understand how business-critical flows work.
- Before changing a service to see which flows it participates in.
- During incident triage to identify all services in an affected flow.
