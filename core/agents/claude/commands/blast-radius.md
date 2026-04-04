Assess the blast radius of a change — what services, flows, and teams are affected.

# Blast Radius

Assess the impact of a change before deploying. Returns the set of services, business flows, and teams that could be affected.

## Usage

```bash
# Check blast radius for a service change
ctx-cli mcp call blast_radius -p service_name=payments-api --raw
```

The response includes:
- **Affected services** — direct and transitive dependents.
- **Affected flows** — business flows that traverse this service.
- **Affected teams** — teams that own impacted services.
- **Risk level** — overall risk assessment (low, medium, high, critical).

## Examples

```bash
# Assess blast radius before a database migration
ctx-cli mcp call blast_radius -p service_name=inventory-db --raw

# Check blast radius for the auth service
ctx-cli mcp call blast_radius -p service_name=auth-service --raw

# Check blast radius for the order service
ctx-cli mcp call blast_radius -p service_name=order-service --raw
```

## When to Use

- Before deploying changes to shared or core services.
- During change review to identify which teams to notify.
- To justify the scope of a rollback during an incident.