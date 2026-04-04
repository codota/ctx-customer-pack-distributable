---
name: understand-flow
description: 'Understand a business flow end-to-end — services involved, ADRs, incidents.'
tags:
  - architecture
  - flows
group: composite
mcp-tools:
  - understand_flow
---
# Understand Flow

Trace a business flow end-to-end through the service graph. See every service involved, relevant ADRs, and incidents that have affected the flow.

## Usage

```bash
# Understand a business flow
ctx-cli mcp call understand_flow -p flow_name=checkout --raw
```

The response includes:
- **Services** — ordered list of services the flow traverses.
- **ADRs** — architecture decision records relevant to the flow.
- **Incidents** — past incidents that affected this flow.
- **SLOs** — service-level objectives defined for the flow.

## Examples

```bash
# Trace the full checkout flow
ctx-cli mcp call understand_flow -p flow_name=checkout --raw

# Understand the payment processing flow
ctx-cli mcp call understand_flow -p flow_name=payment-processing --raw

# Understand the user registration flow
ctx-cli mcp call understand_flow -p flow_name=user-registration --raw
```

## When to Use

- When onboarding to understand how business-critical flows work.
- Before changing a service to see which flows it participates in.
- During incident triage to identify all services in an affected flow.
