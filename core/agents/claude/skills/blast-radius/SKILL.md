---
name: blast-radius
description: >-
  Assess the blast radius of a change — what services, flows, and teams are
  affected.
allowed-tools: mcp__ctx-cloud__blast_radius
---
# Blast Radius

Assess the impact of a change before deploying. Returns the set of services, business flows, and teams that could be affected.

## Usage

**Check blast radius for a service change**
Call `mcp__ctx-cloud__blast_radius` with service_name=payments-api.

The response includes:
- **Affected services** — direct and transitive dependents.
- **Affected flows** — business flows that traverse this service.
- **Affected teams** — teams that own impacted services.
- **Risk level** — overall risk assessment (low, medium, high, critical).

## Examples

**Assess blast radius before a database migration**
Call `mcp__ctx-cloud__blast_radius` with service_name=inventory-db.
**Check blast radius for the auth service**
Call `mcp__ctx-cloud__blast_radius` with service_name=auth-service.
**Check blast radius for the order service**
Call `mcp__ctx-cloud__blast_radius` with service_name=order-service.

## When to Use

- Before deploying changes to shared or core services.
- During change review to identify which teams to notify.
- To justify the scope of a rollback during an incident.
