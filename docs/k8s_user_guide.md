# Tabnine Context Engine -- Kubernetes Deployment Guide

**Version:** Helm Chart 0.2.0 | **Kubernetes:** 1.28+ | **Helm:** 3.15+

This guide walks you through preparing your environment, installing, configuring, upgrading, and maintaining Tabnine Context Engine on Kubernetes. It is written for infrastructure operators and Kubernetes administrators. No prior knowledge of the CTX application is assumed.

---

## Table of Contents

1. [What Is Being Deployed](#1-what-is-being-deployed)
2. [Architecture Overview](#2-architecture-overview)
3. [Infrastructure Prerequisites](#3-infrastructure-prerequisites)
4. [Preparing External Dependencies](#4-preparing-external-dependencies)
5. [Secrets Management](#5-secrets-management)
6. [Storage Setup](#6-storage-setup)
7. [Installation](#7-installation)
8. [Configuration Reference](#8-configuration-reference)
9. [Ingress & TLS](#9-ingress--tls)
10. [Network Policies & Security](#10-network-policies--security)
11. [Scaling & Resource Tuning](#11-scaling--resource-tuning)
12. [Observability](#12-observability)
13. [Upgrades & Rollbacks](#13-upgrades--rollbacks)
14. [Troubleshooting](#14-troubleshooting)
15. [Appendix: Complete Values Reference](#15-appendix-complete-values-reference)

---

## 1. What Is Being Deployed

Tabnine Context Engine (CTX) is an AI agent orchestration platform. It ingests data from external sources (GitHub, GitLab, Jira, Slack, PagerDuty), builds a knowledge graph, and orchestrates AI agents via workflows. The Helm chart deploys all CTX application components onto your Kubernetes cluster.

**What the chart deploys:** 5 long-running services, 3 persistent volume claims, Helm hook jobs, RBAC, network policies, and ingress resources.

**What the chart does NOT deploy:** Databases. PostgreSQL, Neo4j, and Temporal are external dependencies that you manage separately (see [Section 4](#4-preparing-external-dependencies)).

### The "Cell" Model

One Helm release = one **cell**. A cell is a self-contained CTX deployment scoped to one environment and one set of users. You might have:

- `ctx-prod-us` -- production cell for US users
- `ctx-staging` -- staging environment for testing
- `ctx-enterprise-acme` -- dedicated cell for a specific customer

Each cell is fully independent. Multiple cells can run in the same cluster (in separate namespaces) or on different clusters.

---

## 2. Architecture Overview

### High-Level Flow

```mermaid
flowchart LR
    Users["Users & API Clients"] --> Ingress["Ingress Controller<br/>(nginx)"]

    subgraph cell ["CTX Cell (your namespace)"]
        Ingress --> Web["Web UI<br/>React SPA<br/>port 3000"]
        Ingress --> API["API Server<br/>Express REST<br/>port 3005"]
        Ingress --> MCP["MCP Server<br/>port 3006"]

        API --> ExecCtrl["Execution<br/>Controller<br/>port 3007"]
        Worker["Temporal Worker"] --> ExecCtrl

        ExecCtrl --> LSPMCP["LSPMCP Pods<br/>(dynamic)"]
        ExecCtrl --> Terminal["Terminal Pods<br/>(dynamic)"]
    end

    API --> PG["PostgreSQL"]
    API --> Neo4j["Neo4j"]
    API --> Temporal["Temporal Server"]
    Worker --> PG
    Worker --> Neo4j
    Worker --> Temporal
    MCP --> PG
    MCP --> Neo4j

    style cell fill:#f0f4ff,stroke:#3366cc
    style PG fill:#fff3e0,stroke:#ff9800
    style Neo4j fill:#fff3e0,stroke:#ff9800
    style Temporal fill:#fff3e0,stroke:#ff9800
```

### Component Descriptions

**Control Plane** (long-lived, no untrusted code execution):

| Component | What it does | Replicas | Exposed? |
|-----------|-------------|----------|----------|
| **Web** | Serves the React dashboard via nginx. Stateless -- no database access. | 2 | Yes (public) |
| **API** | REST API server. Talks to PostgreSQL, Neo4j, Temporal. Handles user authentication and all CRUD. | 2 | Yes (public) |
| **MCP** | Model Context Protocol HTTP server. Exposes tools for AI model consumption. | 1 (session state is in-memory; phase 2 enables scaling) | Yes (public by default; auth required in prod) |
| **Execution Controller** | Singleton service that creates and destroys LSPMCP and terminal pods. The **only** component with Kubernetes API access. | 1 | No (internal only) |

**Execution Plane** (runs untrusted code, public internet egress):

| Component | What it does | Replicas | Exposed? |
|-----------|-------------|----------|----------|
| **Worker** | Runs Temporal workflows -- agent execution, datasource sync, repo analysis. Pulls work from Temporal (no inbound traffic). | 2 | No (internal only) |
| **LSPMCP Pods** | Dynamically spawned code analysis containers. | configurable | No (internal only) |
| **Terminal Pods** | Dynamically spawned interactive environments (git, package managers, AI CLIs). | on-demand | No (internal only) |

### Control Plane vs. Execution Plane

```mermaid
flowchart TB
    subgraph cp ["Control Plane (long-lived pods)"]
        Web
        API
        MCP
        ExecCtrl["Execution Controller"]
    end

    subgraph ep ["Execution Plane"]
        Worker
        L1["LSPMCP Pod #1"]
        L2["LSPMCP Pod #2"]
        L3["LSPMCP Pod #..."]
        T1["Terminal Pod #1"]
    end

    ExecCtrl -->|"creates/destroys<br/>via K8s API"| L1
    ExecCtrl -->|"creates/destroys<br/>via K8s API"| L2
    ExecCtrl -->|"creates/destroys<br/>via K8s API"| L3
    ExecCtrl -->|"creates/destroys<br/>via K8s API"| T1

    style cp fill:#e8f5e9,stroke:#4caf50
    style ep fill:#fce4ec,stroke:#e91e63
```

- **Control plane** pods are deployed by Helm and always running.
- **Execution plane** pods are dynamically created and destroyed by the execution controller at runtime. They do not appear in the Helm release -- they are spawned via the Kubernetes API as needed. You will see them appear and disappear in your namespace as users work.

### RBAC Model

```mermaid
flowchart LR
    subgraph sa ["Service Accounts"]
        SA_API["ctx-api<br/>No K8s access"]
        SA_MCP["ctx-mcp<br/>No K8s access"]
        SA_Web["ctx-web<br/>No K8s access"]
        SA_Worker["ctx-worker<br/>No K8s access"]
        SA_EC["ctx-execution-controller<br/>Pod/Exec/Service CRUD"]
        SA_WL["ctx-lspmcp-workload<br/>No K8s access"]
        SA_Hooks["ctx-hooks<br/>No K8s access"]
    end

    SA_EC -->|"manages"| Pods["LSPMCP & Terminal Pods"]

    style SA_EC fill:#fff3e0,stroke:#ff9800
    style SA_API fill:#e8f5e9,stroke:#4caf50
    style SA_MCP fill:#e8f5e9,stroke:#4caf50
    style SA_Web fill:#e8f5e9,stroke:#4caf50
    style SA_Worker fill:#e8f5e9,stroke:#4caf50
    style SA_WL fill:#e8f5e9,stroke:#4caf50
    style SA_Hooks fill:#e8f5e9,stroke:#4caf50
```

**Key security property:** Only the execution controller can talk to the Kubernetes API. Every other pod (API, MCP, Web, Worker, LSPMCP workloads, hook jobs) has `automountServiceAccountToken: false` and zero Kubernetes permissions. This means even if an attacker compromises the API pod, they cannot create or modify other pods.

---

## 3. Infrastructure Prerequisites

Before installing CTX, confirm that the following are in place on your cluster.

### Checklist

```
[ ] Kubernetes cluster >= 1.28
[ ] Helm >= 3.15 installed on your workstation
[ ] ingress-nginx controller running in the cluster
[ ] cert-manager installed (for automatic TLS certificates)
[ ] NetworkPolicy-capable CNI (e.g., Calico, Cilium) -- required for production
[ ] ReadWriteMany (RWX) StorageClass available -- required for multi-node clusters
[ ] Container images pushed to your private registry
[ ] Namespace created for the CTX deployment
[ ] Sufficient cluster resources (see sizing table below)
```

### Cluster Sizing

| Tier | Description | Nodes | vCPU Total | Memory Total | Estimated Cost/mo |
|------|------------|-------|-----------|-------------|-------------------|
| **PoC / Dev** | Single-node, 1 replica each | 1 node (4 vCPU, 16 Gi) | 4 | 16 Gi | ~$250 |
| **Budget Production** | Multi-node, 2 replicas, HPA | 4 nodes (4 vCPU each) | 16 | 64 Gi | ~$850 |
| **Enterprise HA** | Multi-node, full HPA, PDB | 3-4 nodes (8 vCPU each) | 24-32 | 96-128 Gi | ~$1,400 |

> **Tip:** The worker pods are the most resource-hungry (up to 12 Gi memory limit) because they run AI agent workflows. Size your nodes accordingly, or use node pools with dedicated large-memory nodes for workers.

### Installing Prerequisites

**ingress-nginx** (if not already installed):
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

**cert-manager** (if not already installed):
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.install=true

# Create a ClusterIssuer for Let's Encrypt:
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com    # <-- change this
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

**Namespace** for CTX:
```bash
kubectl create namespace ctx
```

---

## 4. Preparing External Dependencies

CTX requires three external services. These are **not** deployed by the Helm chart. You are responsible for provisioning and maintaining them.

### Dependency Overview

```mermaid
flowchart LR
    subgraph cluster ["Your Kubernetes Cluster"]
        CTX["CTX Cell"]
    end

    subgraph ext ["External Services (you manage)"]
        PG["PostgreSQL 14+<br/>+ pgvector extension<br/>Port 5432"]
        Neo["Neo4j 5.x<br/>Community or Enterprise<br/>Port 7687"]
        Temp["Temporal Server<br/>Self-hosted or Cloud<br/>Port 7233"]
    end

    subgraph opt ["Optional Services"]
        Redis["Redis 7+<br/>Rate limiting<br/>Port 6379"]
        CH["ClickHouse<br/>Analytics<br/>Port 8123"]
        OFGA["OpenFGA<br/>Authorization<br/>Port 8080"]
    end

    CTX --> PG
    CTX --> Neo
    CTX --> Temp
    CTX -.->|"optional"| Redis
    CTX -.->|"optional"| CH
    CTX -.->|"optional"| OFGA

    style ext fill:#fff3e0,stroke:#ff9800
    style opt fill:#f5f5f5,stroke:#9e9e9e
```

### PostgreSQL

**Required.** CTX stores tenants, agent configurations, credentials, and run history in PostgreSQL.

- **Version:** 14 or higher
- **Extension:** `pgvector` must be installed (used for embedding storage)
- **SSL:** Configure `deps.postgres.sslMode` to match your server (`require`, `verify-ca`, or `verify-full` recommended for production)
- **Database:** Create a database and user for CTX before installing

```sql
-- Run on your PostgreSQL server:
CREATE USER ctx WITH PASSWORD 'your-secure-password';
CREATE DATABASE ctx OWNER ctx;
-- pgvector must be installed as a superuser:
\c ctx
CREATE EXTENSION IF NOT EXISTS vector;
```

**Helm values:**
```yaml
deps:
  postgres:
    host: postgres.your-domain.internal   # DNS name or IP
    port: 5432                            # default port
    database: ctx                         # database name
    username: ctx                         # database user
    sslMode: require                      # TLS mode
```

### Neo4j

**Required.** CTX stores its knowledge graph (services, dependencies, code relationships) in Neo4j.

- **Version:** 5.x (Community or Enterprise)
- **Bolt port:** 7687 (default)

**Helm values:**
```yaml
deps:
  neo4j:
    host: neo4j.your-domain.internal
    port: 7687
    username: neo4j
```

### Temporal

**Required.** CTX uses Temporal for workflow orchestration (agent execution, data ingestion, scheduled tasks).

- **Version:** Compatible with Temporal SDK v1.x
- **Options:** Self-hosted Temporal Server, or Temporal Cloud
- **Port:** 7233 (default gRPC port)
- **mTLS:** Optional but recommended for production

**Helm values (without mTLS):**
```yaml
deps:
  temporal:
    address: temporal.your-domain.internal:7233
    namespace: default
```

**Helm values (with mTLS):**
```yaml
deps:
  temporal:
    address: temporal.your-domain.internal:7233
    namespace: default
    tls:
      enabled: true
      certPath: /etc/temporal/tls/tls.crt
      keyPath: /etc/temporal/tls/tls.key
      caPath: /etc/temporal/tls/ca.crt
      serverName: temporal.your-domain.internal
```

### Redis (Optional)

Redis provides distributed rate limiting. If not enabled, CTX falls back to in-memory rate limiting, which is perfectly fine for single-tenant self-hosted deployments.

```yaml
deps:
  redis:
    enabled: true
    tls: true     # recommended for production
# The Redis connection URL goes in your secrets (key: redis_url)
```

### ClickHouse (Optional)

Analytics and telemetry storage. Only needed if you want detailed tool-call analytics.

```yaml
deps:
  clickhouse:
    enabled: true
    host: clickhouse.your-domain.internal
    port: 8123
    database: ctx
    username: ctx
# The ClickHouse password goes in your secrets (key: clickhouse_password)
```

---

## 5. Secrets Management

CTX never stores secrets as plaintext in Helm values. There are two supported approaches.

### Option A: Pre-Existing Kubernetes Secret (Simpler)

You create a Kubernetes Secret before running `helm install`. This works with any secret management pipeline -- Vault Agent, Sealed Secrets, SOPS, or even manual creation.

```bash
# The secret name MUST match: {release-name}-ctx-secrets
# For example, if you run "helm install ctx ..." the name is "ctx-ctx-secrets"
# Tip: run helm template to verify the exact name (see below)

kubectl create secret generic ctx-ctx-secrets \
  --namespace ctx \
  --from-literal=app_db_password='your-postgres-password' \
  --from-literal=neo4j_password='your-neo4j-password' \
  --from-literal=encryption_key=$(openssl rand -hex 32) \
  --from-literal=api_key_pepper=$(openssl rand -hex 16) \
  --from-literal=admin_secret_key=$(openssl rand -hex 16)
```

**How to verify the expected secret name:**
```bash
helm template my-release ./deploy/charts/ctx \
  --set global.image.registry=example.com \
  --set global.image.tag=test | grep secretName
```

**Helm values:**
```yaml
secrets:
  provider: kubernetes
```

### Required Secret Keys

| Key | Purpose | How to Generate |
|-----|---------|----------------|
| `app_db_password` | PostgreSQL password | From your database provisioning |
| `neo4j_password` | Neo4j password | From your Neo4j setup |
| `encryption_key` | Encrypts sensitive data at rest | `openssl rand -hex 32` |
| `api_key_pepper` | Hashes API keys | `openssl rand -hex 16` |
| `admin_secret_key` | Admin API authentication | `openssl rand -hex 16` |

### Optional Secret Keys (Add When Needed)

| Key | When Required |
|-----|--------------|
| `redis_url` | When `deps.redis.enabled=true` (format: `rediss://user:pass@host:6380`) |
| `openfga_api_token` | When `deps.openfga.enabled=true` |
| `clickhouse_password` | When `deps.clickhouse.enabled=true` |

### Option B: External Secrets Operator (ESO)

If you use a cloud key vault (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager, HashiCorp Vault), the chart can create an `ExternalSecret` resource that tells ESO to pull secrets from your vault and create the Kubernetes Secret automatically.

**Prerequisites:**
1. External Secrets Operator installed in the cluster
2. A `SecretStore` or `ClusterSecretStore` configured to point at your vault
3. The required secrets stored in your vault

```mermaid
sequenceDiagram
    participant Helm
    participant K8s as Kubernetes API
    participant ESO as External Secrets Operator
    participant Vault as Cloud Key Vault

    Helm->>K8s: Create ExternalSecret (pre-install hook, weight -20)
    K8s->>ESO: ExternalSecret detected
    ESO->>Vault: Fetch secrets
    Vault-->>ESO: Return secret values
    ESO->>K8s: Create/update K8s Secret
    Note over Helm,K8s: db-migrate job starts (hook weight -5)
    K8s->>K8s: Init container waits for Secret
    K8s-->>K8s: Secret populated, init container passes
    K8s->>K8s: Migration runs
```

**Helm values for Azure Key Vault:**
```yaml
secrets:
  provider: external
  external:
    secretStoreName: my-keyvault-store   # your SecretStore name
    secretStoreKind: ClusterSecretStore  # or SecretStore (case-sensitive, only these two values accepted)
    refreshInterval: 1h                  # how often ESO re-syncs
    cloudProvider: azure
  # Map: Helm secret key -> remote secret name in your vault
  # All required keys MUST have non-blank values (the remote secret name in your vault)
  keys:
    app_db_password: ctx-db-password
    neo4j_password: ctx-neo4j-password
    encryption_key: ctx-encryption-key
    api_key_pepper: ctx-api-key-pepper
    admin_secret_key: ctx-admin-secret-key
  optionalKeys:
    redis_url: ctx-redis-url
    openfga_api_token: ctx-openfga-api-token
    clickhouse_password: ctx-clickhouse-password
```

> **How the timing works:** The ExternalSecret is deployed as a Helm pre-install hook at weight `-20`. The db-migrate job is deployed at weight `-5`. The db-migrate job has an init container that polls for up to 120 seconds waiting for the secret to appear. This gives ESO time to populate the secret before migrations run.

---

## 6. Storage Setup

CTX requires shared persistent storage for code repositories and indexes used by the LSPMCP analysis engine.

### How Storage Works

```mermaid
flowchart LR
    subgraph pvcs ["Persistent Volume Claims"]
        Repos["ctx-lspmcp-repos<br/>100 Gi"]
        Indexes["ctx-lspmcp-indexes<br/>50 Gi"]
        Outputs["ctx-agent-outputs<br/>50 Gi"]
    end

    API --> Repos
    API --> Indexes
    API --> Outputs
    Worker --> Repos
    Worker --> Indexes
    LSPMCP["LSPMCP Pods"] --> Repos
    LSPMCP --> Indexes

    style pvcs fill:#e3f2fd,stroke:#1976d2
```

Multiple pods read and write these volumes simultaneously, which is why you need **ReadWriteMany (RWX)** access mode on multi-node clusters.

### StorageClass by Cloud Provider

| Provider | StorageClass | CSI Driver | Notes |
|----------|-------------|-----------|-------|
| **GKE** | `standard-rwx` | Filestore CSI | Enable Filestore in GKE |
| **EKS** | `efs-sc` | EFS CSI driver | Must install EFS CSI driver add-on |
| **AKS** | `azurefile-csi-nfs` | Azure Files CSI | Use **NFS** protocol, not SMB. SMB has permission issues with non-root pods. |
| **OpenShift** | `ocs-storagecluster-cephfs` | OCS | Or any NFS-based StorageClass |
| **Bare Metal** | varies | NFS provisioner | Must provide an NFS-backed StorageClass |
| **Minikube** | _(default)_ | hostpath | Use ReadWriteOnce -- works because single-node |

**Helm values:**
```yaml
persistence:
  accessMode: ReadWriteMany    # ReadWriteOnce for single-node only
  storageClass: azurefile-csi-nfs   # set to your RWX StorageClass
  repos:
    size: 100Gi    # repository storage
  indexes:
    size: 50Gi     # index storage
  outputs:
    size: 50Gi     # agent output storage
```

> **Single-node exception:** If you are running on a single-node cluster (Minikube, kind, or a single-node dev AKS), you can use `ReadWriteOnce` because all pods are colocated on the same node. RWO allows concurrent access when all consumers are on the same node.

### Verifying Your StorageClass

```bash
# List available StorageClasses:
kubectl get storageclass

# Check if your StorageClass supports RWX:
kubectl get storageclass <name> -o yaml | grep -A5 allowedAccessModes
# Note: not all CSI drivers report this field; consult your driver docs
```

---

## 7. Installation

### Step-by-Step Installation

#### Step 1: Add Chart Repository (or Copy Chart)

The chart is distributed as part of the CTX source code at `deploy/charts/ctx/`. Copy it to your deployment workstation or CI pipeline.

#### Step 2: Create Your Values Override File

Start from one of the provided overlays and customize:

| Starting Point | File | Use When |
|---------------|------|----------|
| Production | `values-production.yaml` | Multi-node, HA, self-hosted |
| Staging | `values-staging.yaml` | Pre-prod testing |
| Azure AKS | `values-azure.yaml` | Azure-specific configs |
| Minikube | `values-minikube.yaml` | Local PoC / demo |

```bash
# Copy and customize:
cp deploy/charts/ctx/values-production.yaml my-values.yaml
# Edit my-values.yaml with your specific settings...
```

#### Step 3: Create Namespace and Secrets

```bash
kubectl create namespace ctx

# Option A: Pre-existing secret
kubectl create secret generic ctx-ctx-secrets \
  --namespace ctx \
  --from-literal=app_db_password='...' \
  --from-literal=neo4j_password='...' \
  --from-literal=encryption_key=$(openssl rand -hex 32) \
  --from-literal=api_key_pepper=$(openssl rand -hex 16) \
  --from-literal=admin_secret_key=$(openssl rand -hex 16)
```

#### Step 4: Dry Run (Recommended)

Before actually installing, verify that the rendered templates look correct:

```bash
helm template ctx ./deploy/charts/ctx \
  -f my-values.yaml \
  --namespace ctx \
  --set global.image.registry=myregistry.example.com/ctx \
  --set global.image.tag=v1.2.3 \
  | less
```

Look for:
- Correct image references
- Correct secret name
- Correct dependency hostnames
- Expected number of replicas

#### Step 5: Install

```bash
helm install ctx ./deploy/charts/ctx \
  -f my-values.yaml \
  --namespace ctx \
  --set global.image.registry=myregistry.example.com/ctx \
  --set global.image.tag=v1.2.3 \
  --wait \
  --timeout 10m
```

The `--wait` flag tells Helm to wait until all pods are ready. The `--timeout 10m` gives time for:
1. ExternalSecret to sync with vault (if using ESO) — async, operator-driven
2. Preflight job to validate dependencies (if enabled) — hook weight `-10`
3. Database migration to run — hook weight `-5`
4. All deployments to roll out

### What Happens During Install

```mermaid
sequenceDiagram
    participant H as Helm
    participant K as Kubernetes
    participant ESO as ESO (if external)

    H->>K: 1. Create ExternalSecret (pre-install hook, weight -20)
    ESO->>K: Populate K8s Secret from vault (async)
    H->>K: 2. Run preflight job (weight -10)
    Note over K: Validates Postgres, Neo4j, Temporal connectivity
    H->>K: 3. Run db-migrate job (weight -5)
    Note over K: Creates/updates database schema
    H->>K: 4. Create all resources (deployments, services, ingress...)
    Note over K: Pods start, pass readiness probes
    H-->>H: 5. Helm reports "deployed"
```

### Minimal Production Install (Copy-Paste)

If you want the absolute minimum values for a production install:

```bash
helm install ctx ./deploy/charts/ctx \
  --namespace ctx \
  --set global.image.registry=myregistry.example.com/ctx \
  --set global.image.tag=v1.2.3 \
  --set global.environment=prod \
  --set ingress.host=ctx.example.com \
  --set deps.postgres.host=postgres.internal \
  --set deps.neo4j.host=neo4j.internal \
  --set deps.temporal.address=temporal.internal:7233 \
  --set secrets.provider=kubernetes \
  --set ingress.mcp.authAnnotations."nginx\.ingress\.kubernetes\.io/auth-url"=https://auth.example.com/verify \
  --wait --timeout 10m
```

That's 9 values. Everything else has production-safe defaults. MCP is public by default and production requires auth annotations — this is the MCP auth endpoint that protects the `/mcp` routes.

### Verifying the Installation

```bash
# Check all pods are running:
kubectl get pods -n ctx -l app.kubernetes.io/instance=ctx

# Expected output (production):
# ctx-api-xxxxx-yyy          1/1   Running
# ctx-api-xxxxx-zzz          1/1   Running
# ctx-web-xxxxx-yyy          1/1   Running
# ctx-web-xxxxx-zzz          1/1   Running
# ctx-mcp-xxxxx-yyy          1/1   Running
# ctx-mcp-xxxxx-zzz          1/1   Running
# ctx-worker-xxxxx-yyy       1/1   Running
# ctx-worker-xxxxx-zzz       1/1   Running
# ctx-execution-controller-xxxxx-yyy   1/1   Running

# Check the API health:
kubectl exec -n ctx deploy/ctx-api -- wget -qO- http://localhost:3005/ready

# Check the MCP health:
kubectl exec -n ctx deploy/ctx-mcp -- wget -qO- http://localhost:3006/ready

# Check ingress:
kubectl get ingress -n ctx

# Check PVCs are bound:
kubectl get pvc -n ctx
```

---

## 8. Configuration Reference

### Global Settings

```yaml
global:
  environment: prod          # "staging" or "prod"
                             # "prod" enables install-time safety guardrails
  deploymentMode: self-hosted  # only "self-hosted" in Phase 1
  image:
    registry: ''             # REQUIRED -- your container registry path
    tag: ''                  # REQUIRED -- image tag (git SHA or version)
    pullPolicy: IfNotPresent # When to pull images
    pullSecrets: []          # Image pull secret names for private registries
  logLevel: info             # info | debug
  logFormat: json            # Always JSON for structured logging
  customCA:
    enabled: false           # Set true if you use self-signed certificates
    configMapName: ''        # Name of ConfigMap with your CA bundle
    key: ca-bundle.crt       # Key in the ConfigMap containing the PEM file
```

### Per-Component Settings

Each component (api, web, mcp, worker) follows the same pattern:

```yaml
api:                         # (or: web, mcp, worker)
  image:
    registry: ''             # Override global registry for this component
    repository: ctx-api      # Image name
    tag: ''                  # Override global tag for this component
  replicaCount: 2            # Number of pod replicas
  port: 3005                 # Container port
  resources:
    requests:
      memory: 256Mi          # Minimum guaranteed memory
      cpu: 250m              # Minimum guaranteed CPU
    limits:
      memory: 1Gi            # Maximum memory (OOMKilled if exceeded)
      cpu: 1000m             # Maximum CPU (throttled if exceeded)
  hpa:
    enabled: true            # Enable Horizontal Pod Autoscaler
    minReplicas: 2           # Minimum replicas
    maxReplicas: 5           # Maximum replicas
    targetCPUUtilizationPercentage: 70  # Scale up at 70% CPU
  pdb:
    enabled: true            # Enable Pod Disruption Budget
    minAvailable: 1          # At least 1 pod during voluntary disruptions
  nodeSelector: {}           # Pin pods to specific nodes
  tolerations: []            # Tolerate specific node taints
  env: {}                    # Extra environment variables
```

### Resource Recommendations

| Component | Requests (memory / CPU) | Limits (memory / CPU) | Notes |
|-----------|------------------------|----------------------|-------|
| API | 256 Mi / 250m | 1 Gi / 1000m | Moderate -- handles HTTP traffic |
| Web | 64 Mi / 50m | 256 Mi / 200m | Light -- just serves static files |
| MCP | 128 Mi / 100m | 512 Mi / 500m | Moderate -- similar to API |
| Worker | 1 Gi / 1000m | **12 Gi** / 4000m | **Heavy** -- runs AI agent workflows |
| Exec Controller | 128 Mi / 100m | 256 Mi / 250m | Light -- just manages pod lifecycle |
| LSPMCP Pods | 512 Mi / 250m | 2 Gi / 1000m | Per dynamic pod |

> **Warning:** Worker memory limits are high (12 Gi) because AI agent workflows can be memory-intensive. If your worker pods are getting OOMKilled, increase the limit. If you are running on small nodes, reduce `TEMPORAL_WORKER_MAX_AGENT_ACTIVITIES` to limit concurrent agent workloads.

---

## 9. Ingress & TLS

### Ingress Architecture

```mermaid
flowchart TB
    Internet["Internet"] --> LB["Load Balancer<br/>(cloud-provisioned)"]

    LB --> IC["ingress-nginx<br/>Controller"]

    IC -->|"ctx.example.com/api/*"| API["API Service<br/>port 80 -> 3005"]
    IC -->|"ctx.example.com/ws/*"| API
    IC -->|"ctx.example.com/*"| Web["Web Service<br/>port 80 -> 3000"]

    IC2["Internal Ingress<br/>(optional)"] -->|"admin.ctx.internal/api/admin/*"| API
    IC2 -->|"admin.ctx.internal/metrics"| API

    style IC fill:#e3f2fd,stroke:#1976d2
    style IC2 fill:#fff3e0,stroke:#ff9800
```

### Ingress Resources Created

The chart creates up to 4 Ingress resources:

| Ingress | Path(s) | Backend | Purpose |
|---------|---------|---------|---------|
| `ctx` | `/api/*` | API (port 80) | REST API calls |
| `ctx` | `/*` | Web (port 80) | Dashboard (catch-all) |
| `ctx-admin-block` | `/api/admin/*` | Web (port 80) | **Blocks** public admin access (returns 404) |
| `ctx-ws` | `/ws/*` | API (port 80) | WebSocket (5min timeout, sticky sessions) |
| `ctx-private` | `/api/admin/*`, `/metrics` | API (port 80) | Private admin access (separate ingress class) |

### TLS Certificates

Production requires a cert source — either cert-manager or a pre-existing TLS Secret. The chart rejects installs with TLS enabled but no cert source. By default, cert-manager auto-provisions:

```yaml
ingress:
  host: ctx.example.com
  tls:
    enabled: true          # REQUIRED in prod
    secretName: ''         # Empty = cert-manager auto-provisions
  certManager:
    enabled: true
    issuer: letsencrypt-prod  # Must match your ClusterIssuer name
```

**To use your own certificate** (e.g., from an enterprise CA):
```bash
# Create a TLS secret:
kubectl create secret tls ctx-tls \
  --namespace ctx \
  --cert=/path/to/tls.crt \
  --key=/path/to/tls.key

# Then in values:
ingress:
  tls:
    enabled: true
    secretName: ctx-tls    # reference your secret
  certManager:
    enabled: false          # disable cert-manager
```

### Admin Access

By default, admin API routes are **blocked on the public ingress** (the `/api/admin/*` block route returns 404). To access admin features, configure a private ingress:

```yaml
identity:
  adminAccess:
    mode: private          # "disabled" (default) or "private"

ingress:
  private:
    host: admin.ctx.internal   # accessible only from your VPN/internal network
    className: nginx-internal  # a separate ingress controller class
    tls:
      secretName: ''           # cert-manager auto-provisions, or set to pre-existing Secret
```

This creates a separate Ingress resource on a different ingress controller (e.g., one that is only reachable from your internal network). Production requires TLS on the private ingress — admin credentials must not be transmitted in cleartext.

### CORS

For production, you must specify the allowed origins explicitly:
```yaml
api:
  env:
    CORS_ALLOWED_ORIGINS: "https://ctx.example.com"
```

> **Note:** If you leave `CORS_ALLOWED_ORIGINS` empty, the chart auto-derives it from `ingress.host` as `https://{host}`. A wildcard (`*`) is rejected in production.

---

## 10. Network Policies & Security

### Network Policy Overview

When `networkPolicies.egressMode: private-ranges` (the default for production), the chart creates a **default-deny** policy for all pods in the namespace, then adds specific per-component allowlists.

```mermaid
flowchart TB
    subgraph deny ["Default Deny (all pods)"]
        direction TB
        DD["No ingress or egress<br/>unless explicitly allowed"]
    end

    subgraph allow ["Per-Component Allowlists"]
        A_API["API<br/>+ ingress-nginx in<br/>+ DNS, deps, LSPMCP out"]
        A_Web["Web<br/>+ ingress-nginx in<br/>+ nothing out"]
        A_MCP["MCP<br/>+ ingress-nginx in<br/>+ DNS, deps out"]
        A_Worker["Worker<br/>+ release pods in<br/>+ DNS, deps, public 443 out*"]
        A_EC["Exec Controller<br/>+ release pods in<br/>+ DNS, K8s API out"]
        A_LSPMCP["LSPMCP<br/>+ release pods in<br/>+ no internet out"]
        A_Term["Terminal<br/>+ API/MCP in<br/>+ public 443/80/22 out*"]
    end

    deny --> allow

    style deny fill:#ffebee,stroke:#c62828
    style A_EC fill:#fff3e0,stroke:#ff9800
    style A_Term fill:#fff3e0,stroke:#ff9800
```

### Egress Modes

| Mode | NetworkPolicies Created? | Use Case |
|------|------------------------|----------|
| `private-ranges` | Yes -- default-deny + allowlists | **Production.** External egress limited to RFC 1918 private ranges. |
| `disabled` | No | Staging, Minikube, or clusters without CNI support. |

### Configuring Network Policies

```yaml
networkPolicies:
  egressMode: private-ranges

  # Which namespace runs CoreDNS? (OpenShift uses "openshift-dns")
  dnsNamespace: kube-system

  # Which namespace runs the ingress controller?
  ingressNamespace: ingress-nginx

  # Optional: internal ingress namespace for private admin access
  privateIngressNamespace: ingress-nginx-internal

  # Optional: Prometheus namespace (for scraping)
  prometheusNamespace: monitoring

  # Optional: tighten K8s API server egress to exact CIDR
  kubeApiCidr: "10.96.0.1/32"

  # Optional: extra egress rules for managed services
  externalEgress:
    - cidr: 10.0.1.0/24       # e.g., managed PostgreSQL subnet
      ports: [5432]
    - cidr: 10.0.2.0/24       # e.g., managed Neo4j subnet
      ports: [7687]
    - cidr: 10.0.3.0/24       # e.g., Temporal subnet
      ports: [7233]
```

### Terminal Internet Access (Security Trade-Off)

Terminal pods allow users to run git, install packages (npm, pip), and use AI CLI tools. These require public internet access. By default, terminal pods can reach **public** internet on ports 443, 80, and 22 — RFC 1918 private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) are excluded so terminal pods cannot reach in-cluster services via these ports.

```yaml
networkPolicies:
  terminal:
    allowInternet: true   # default; set false for air-gapped environments
```

> **If your security policy prohibits any public internet egress:** Set `allowInternet: false`. Terminal sessions will still work for in-cluster operations but cannot reach external services (no git clone from GitHub, no npm install, etc.).

### Custom CA Certificates

If your organization uses a private PKI (self-signed certificates for internal services), CTX can trust your CA:

```bash
# Step 1: Create a ConfigMap with your CA bundle
kubectl create configmap ctx-custom-ca \
  --namespace ctx \
  --from-file=ca-bundle.crt=/path/to/your-ca-bundle.pem

# Step 2: Enable in values
global:
  customCA:
    enabled: true
    configMapName: ctx-custom-ca
    key: ca-bundle.crt        # must match the key in the ConfigMap
```

The chart mounts this CA into every pod and sets `NODE_EXTRA_CA_CERTS` so that all HTTPS connections trust your internal certificates. This is required if your PostgreSQL, Neo4j, or Temporal servers use certificates signed by a private CA.

### Pod Security

Every pod deployed by this chart runs with a hardened security context:

```yaml
# Applied to ALL pods automatically -- you do not configure this:
securityContext:
  runAsNonRoot: true          # no root processes
  runAsUser: 1000             # UID 1000 (node user)
  runAsGroup: 1000            # GID 1000
  readOnlyRootFilesystem: true   # filesystem is immutable
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]             # no Linux capabilities
  seccompProfile:
    type: RuntimeDefault      # seccomp filtering enabled
```

These settings meet the Kubernetes Pod Security Admission `restricted` profile. The chart provides writable `emptyDir` volumes at `/tmp` and `/home/node` for runtime needs.

### Production Guardrails

When you set `global.environment: prod`, the chart validates your configuration at install time and **fails** if any of these conditions are true:

| Guard | What it checks | Why |
|-------|---------------|-----|
| TLS Required | `ingress.tls.enabled` must be `true` | Prevents unencrypted traffic |
| Host Required | `ingress.host` must be set | Prevents catch-all routing |
| Network Policies | `egressMode` must be `private-ranges` | Prevents open network |
| Secrets Provider | Must be `kubernetes` or `external` | Prevents inline secrets |
| CORS | Cannot be `*` wildcard | Prevents cross-origin attacks |
| Admin Access | Must be `private` or `disabled` | Prevents public admin |
| Dependencies | Postgres, Neo4j, Temporal hosts must be set | Prevents broken installs |
| MCP Auth | If public MCP, `authAnnotations` required | Prevents unauthenticated MCP |

If any guard fails, Helm prints an error message explaining what needs to be fixed.

---

## 11. Scaling & Resource Tuning

### Horizontal Pod Autoscaling

```mermaid
flowchart LR
    subgraph hpa ["HPA Configuration"]
        A["API<br/>min: 2 → max: 5<br/>@ 70% CPU"]
        W["Web<br/>min: 2 → max: 4<br/>@ 70% CPU"]
        M["MCP<br/>1 replica (phase 1)<br/>HPA in phase 2"]
    end

    subgraph manual ["Manual / KEDA Scaling"]
        WK["Worker<br/>Static replicas: 2<br/>(or KEDA by queue depth)"]
        EC["Exec Controller<br/>Singleton: 1"]
    end

    style hpa fill:#e8f5e9,stroke:#4caf50
    style manual fill:#e3f2fd,stroke:#1976d2
```

HPA is enabled by default for API and Web. MCP is singleton in phase 1 (sessions are in-memory). Workers are not autoscaled by default because their resource usage is driven by workflow queue depth rather than CPU — if you want autoscaling for workers, enable KEDA:

```yaml
worker:
  keda:
    enabled: true
    pollingInterval: 15        # seconds between queue depth checks
    minReplicaCount: 1
    maxReplicaCount: 20
    triggers:                  # REQUIRED: at least one trigger definition
      - type: prometheus
        metadata:
          query: sum(rate(temporal_workflow_task_schedule_to_start_latency_count[5m]))
          threshold: "10"
```

> **KEDA requires its CRDs installed.** If the CRDs are absent, the chart gracefully degrades: the ScaledObject is skipped and the worker keeps its static `replicaCount`. This is intentional — the worker continues running, just without autoscaling. `triggers` must contain at least one entry when `keda.enabled=true`.

### Pod Disruption Budgets

PDBs protect against voluntary disruptions (node drains, cluster upgrades):

| Component | minAvailable | What this means |
|-----------|-------------|----------------|
| API | 1 | At least 1 API pod stays running during drain |
| Web | 1 | At least 1 Web pod stays running |
| MCP | 1 | At least 1 MCP pod stays running |
| Worker | 0 | Workers can be fully evicted (workflows resume via Temporal) |

> **Why is worker minAvailable=0?** Temporal has built-in retry and resumption. If all worker pods go down, workflows pause and automatically resume when new worker pods come up. This means it is safe to drain all worker pods during a rolling update.

### Priority Classes

The chart creates two PriorityClasses (cluster-scoped resources):

| PriorityClass | Value | Used By |
|--------------|-------|---------|
| `ctx-control-plane` | 1,000,000 | API, Web, MCP, Exec Controller |
| `ctx-execution` | 100,000 | Worker, LSPMCP pods, Terminal pods |

This means if the cluster is under resource pressure, Kubernetes evicts execution plane pods before control plane pods.

> **If your RBAC is namespace-scoped** and you cannot create cluster-scoped resources, set `priorityClasses.create: false`. Pods will use the default scheduler priority. Alternatively, ask a cluster admin to pre-create the PriorityClasses and provide their names:
> ```yaml
> priorityClasses:
>   create: false
>   controlPlane:
>     name: my-existing-high-priority
>   execution:
>     name: my-existing-low-priority
> ```

### Worker Concurrency Tuning

Workers have tunable concurrency controls that affect memory usage:

```yaml
worker:
  env:
    # How many agent workflows run simultaneously (each ~1-2 Gi)
    TEMPORAL_WORKER_MAX_AGENT_ACTIVITIES: '10'
    # How many Temporal workflow tasks to process concurrently
    TEMPORAL_WORKER_MAX_WORKFLOW_TASKS: '10'
    # How many data source sync activities
    TEMPORAL_WORKER_MAX_DATASOURCE_ACTIVITIES: '5'
    # How many deduplication activities
    TEMPORAL_WORKER_MAX_DEDUP_ACTIVITIES: '3'
    # How many LSPMCP activities
    TEMPORAL_WORKER_MAX_LSPMCP_ACTIVITIES: '5'
```

**Reduce these values if:**
- Your nodes have limited memory
- Worker pods are getting OOMKilled
- You are running on a single-node dev cluster

**Increase these values if:**
- You have large nodes with plenty of memory
- Users are waiting for agent execution (queue backlog)
- You have multiple worker replicas to distribute load

### Execution Plane Tuning

```yaml
execution:
  lspmcp:
    maxRunningContainers: 10     # max concurrent LSPMCP pods
    idleTimeoutMs: '1800000'     # 30 min idle before pod is terminated
    indexTimeoutMs: '600000'     # 10 min timeout for indexing operations
    podResources:
      requests:
        cpu: 250m
        memory: 512Mi
      limits:
        cpu: 1000m
        memory: 2Gi
```

---

## 12. Observability

### Health Probes

Every component has Kubernetes health probes configured. These are how Kubernetes knows whether a pod is healthy:

| Component | Readiness Probe | Liveness Probe | Startup Probe |
|-----------|----------------|----------------|---------------|
| API | `GET /ready` every 5s | `GET /health` every 30s | `GET /ready` x30 (5 min window) |
| Web | `GET /` every 5s | `GET /` every 30s | `GET /` x30 |
| MCP | `GET /ready` every 5s | `GET /health` every 30s | `GET /ready` x30 |
| Worker | `GET /ready` every 10s | `GET /health` every 30s | `GET /ready` x30 |
| Exec Controller | `GET /health` every 5s | `GET /health` every 30s | -- |

> **What is the difference?**
> - **Startup probe**: Checks during initial boot. Fails 30 times before Kubernetes gives up (restarts the pod). Gives the app time to initialize databases, load config, etc.
> - **Readiness probe**: Checks if the pod is ready to receive traffic. Failed = removed from Service endpoints (no traffic sent). Succeeds = traffic flows in.
> - **Liveness probe**: Checks if the pod is still alive. Failed = Kubernetes kills and restarts the pod. This catches deadlocks and hung processes.

### Manual Health Checks

```bash
# API readiness (checks database connectivity):
kubectl exec -n ctx deploy/ctx-api -- wget -qO- http://localhost:3005/ready

# MCP readiness:
kubectl exec -n ctx deploy/ctx-mcp -- wget -qO- http://localhost:3006/ready

# Execution controller health:
kubectl exec -n ctx deploy/ctx-execution-controller -- wget -qO- http://localhost:3007/health
```

### Prometheus Monitoring

Enable Prometheus scraping by creating ServiceMonitor resources:

```yaml
observability:
  serviceMonitor:
    enabled: true
    interval: 30s     # scrape every 30 seconds
```

This creates a ServiceMonitor that tells Prometheus to scrape metrics from API, MCP, and Worker pods. You need the Prometheus Operator installed in your cluster for this to work.

### Alerting

Enable pre-built alerting rules:

```yaml
observability:
  prometheusRule:
    enabled: true
```

**Built-in alerts:**

| Alert | Severity | Fires When |
|-------|----------|-----------|
| Pod Crash Loops | Critical | A CTX pod restarts repeatedly |
| API Down | Critical | No API pods are ready |
| Redis Unavailable | Warning | Redis dependency is unreachable |
| Connection Saturation | Warning | Database connection pool is exhausted |
| Worker Queue Backlog | Warning | Temporal queue depth exceeds threshold |
| Execution Failures | Warning | LSPMCP pod creation is failing |

### Distributed Tracing (OTLP)

```yaml
observability:
  otlp:
    enabled: true
    endpoint: http://tempo.monitoring:4318   # your OTLP collector
    sampleRate: 0.1                          # sample 10% of traces
```

### Logging

All pods emit structured JSON logs by default. Use `kubectl logs` or your log aggregator (Loki, Elasticsearch, CloudWatch):

```bash
# View API logs:
kubectl logs -n ctx deploy/ctx-api --tail=100 -f

# View worker logs:
kubectl logs -n ctx deploy/ctx-worker --tail=100 -f

# View migration job logs:
kubectl logs -n ctx job/ctx-db-migrate
```

---

## 13. Upgrades & Rollbacks

### Upgrading CTX

```mermaid
flowchart TB
    A["1. Push new images<br/>to registry"] --> B["2. helm upgrade<br/>with new tag"]
    B --> C{"3. Hooks run<br/>(db-migrate)"}
    C -->|"success"| D["4. Rolling update<br/>of deployments"]
    C -->|"failure"| E["5. Helm rolls back<br/>automatically"]
    D --> F["6. Verify health"]

    style C fill:#fff3e0,stroke:#ff9800
    style E fill:#ffebee,stroke:#c62828
```

**Standard upgrade:**
```bash
# Step 1: Push new images to your registry
# (handled by your CI/CD pipeline)

# Step 2: Upgrade the release
helm upgrade ctx ./deploy/charts/ctx \
  -f my-values.yaml \
  --namespace ctx \
  --set global.image.tag=v1.3.0 \
  --wait \
  --timeout 10m

# Step 3: Verify
kubectl get pods -n ctx
kubectl exec -n ctx deploy/ctx-api -- wget -qO- http://localhost:3005/ready
```

**What happens during upgrade:**
1. If using ESO, the ExternalSecret hook runs (refreshes secrets)
2. The db-migrate job runs (applies new schema migrations, if any)
3. Deployments do a rolling update (old pods stay until new pods are ready)
4. HPA adjusts replica counts if needed

### Rollbacks

If an upgrade fails or causes issues:

```bash
# View release history:
helm history ctx -n ctx

# Roll back to previous version:
helm rollback ctx 1 -n ctx
```

> **Important:** Database migrations are **forward-only**. Rolling back Helm does not roll back database schema changes. If a migration introduced breaking schema changes, you may need to run a manual rollback script or restore from a database backup.

### Changing Configuration (No Image Change)

If you only need to change configuration (replicas, resource limits, env vars, etc.) without changing the image:

```bash
helm upgrade ctx ./deploy/charts/ctx \
  -f my-values.yaml \
  --namespace ctx \
  --reuse-values \
  --set api.replicaCount=3 \
  --wait
```

The `--reuse-values` flag preserves all previous values and only applies your overrides.

---

## 14. Troubleshooting

### Pods Not Starting

```bash
# Check pod status and events:
kubectl describe pod <pod-name> -n ctx

# Common causes:
# - ImagePullBackOff: wrong registry, missing pull secret, or image doesn't exist
# - Pending: insufficient resources (check node capacity)
# - CrashLoopBackOff: application error (check logs)
```

**ImagePullBackOff:**
```bash
# Verify your image exists:
kubectl get pods -n ctx -o jsonpath='{.items[*].spec.containers[*].image}'

# Check pull secrets:
kubectl get secret -n ctx | grep pull
```

**CrashLoopBackOff:**
```bash
# Check the pod logs for the error:
kubectl logs -n ctx <pod-name> --previous
```

### Database Migration Failures

```bash
# Check migration job status:
kubectl get jobs -n ctx

# Check migration logs:
kubectl logs -n ctx job/ctx-db-migrate

# If the init container is stuck waiting for secrets:
kubectl logs -n ctx job/ctx-db-migrate -c wait-for-secrets
```

**Common causes:**
- Secret not created or wrong name
- PostgreSQL unreachable from the cluster
- PostgreSQL user lacks permissions to create tables

### Secrets Not Populating (ESO)

```bash
# Check ExternalSecret status:
kubectl get externalsecret -n ctx
kubectl describe externalsecret ctx-external-secret -n ctx

# Check if the K8s Secret was created:
kubectl get secret -n ctx | grep ctx

# Check ESO operator logs:
kubectl logs -n external-secrets deploy/external-secrets -f
```

### Network Policy Issues

If pods cannot reach their dependencies after enabling network policies:

```bash
# Verify network policies exist:
kubectl get networkpolicy -n ctx

# Test connectivity from API pod to PostgreSQL:
kubectl exec -n ctx deploy/ctx-api -- wget --spider -T5 postgres.internal:5432

# Check if your CNI supports NetworkPolicy:
kubectl get pods -n kube-system | grep -E 'calico|cilium|weave'
```

**Common fixes:**
- Set `networkPolicies.dnsNamespace` to match where CoreDNS runs (OpenShift: `openshift-dns`)
- Add managed service CIDRs to `networkPolicies.externalEgress`
- Set `networkPolicies.kubeApiCidr` if the default private-range rule doesn't cover your K8s API server

### PVC Issues

```bash
# Check PVC status:
kubectl get pvc -n ctx

# If a PVC is stuck in Pending:
kubectl describe pvc ctx-lspmcp-repos -n ctx

# Common causes:
# - StorageClass doesn't exist or doesn't support RWX
# - No capacity available in the storage backend
```

### Health Check Reference

| What to check | Command |
|--------------|---------|
| All pods | `kubectl get pods -n ctx` |
| API health | `kubectl exec -n ctx deploy/ctx-api -- wget -qO- http://localhost:3005/ready` |
| MCP health | `kubectl exec -n ctx deploy/ctx-mcp -- wget -qO- http://localhost:3006/ready` |
| Exec controller | `kubectl exec -n ctx deploy/ctx-execution-controller -- wget -qO- http://localhost:3007/health` |
| Ingress | `kubectl get ingress -n ctx` |
| PVCs | `kubectl get pvc -n ctx` |
| Secrets | `kubectl get secret -n ctx` |
| Network policies | `kubectl get networkpolicy -n ctx` |
| Events | `kubectl get events -n ctx --sort-by=.lastTimestamp` |
| Helm status | `helm status ctx -n ctx` |
| Helm hooks | `kubectl get jobs -n ctx` |

---

## 15. Appendix: Complete Values Reference

### All Settings at a Glance

The following diagram shows all major configuration sections and how they relate:

```mermaid
flowchart TB
    subgraph global ["global.*"]
        env["environment: staging|prod"]
        mode["deploymentMode: self-hosted"]
        img["image.registry, image.tag"]
        log["logLevel, logFormat"]
        ca["customCA.enabled, configMapName"]
    end

    subgraph deps ["deps.*"]
        pg["postgres: host, port, database, sslMode"]
        neo["neo4j: host, port"]
        temp["temporal: address, namespace, tls"]
        redis["redis: enabled, tls"]
        ch["clickhouse: enabled, host"]
        ofga["openfga: enabled, apiUrl"]
    end

    subgraph secrets ["secrets.*"]
        prov["provider: kubernetes|external"]
        eso["external: secretStoreName, kind"]
        keys["keys: app_db_password, ..."]
    end

    subgraph components ["Component Configuration"]
        api["api: replicas, resources, hpa, pdb, env"]
        web["web: replicas, resources, hpa, pdb"]
        mcp["mcp: replicas, resources, hpa, pdb, env"]
        worker["worker: replicas, resources, pdb, keda, env"]
    end

    subgraph infra ["Infrastructure"]
        ingress["ingress: host, tls, certManager, private"]
        np["networkPolicies: egressMode, terminal"]
        persist["persistence: accessMode, storageClass, sizes"]
        exec["execution: lspmcp, terminal"]
        obs["observability: otlp, serviceMonitor, prometheusRule"]
        ops["operations: dbMigrate, preflight, smokeTest"]
        id["identity: adminAccess, workloadIdentity"]
        pc["priorityClasses: create, names"]
    end

    global --> components
    global --> infra
    deps --> components
    secrets --> components

    style global fill:#e8f5e9,stroke:#4caf50
    style deps fill:#fff3e0,stroke:#ff9800
    style secrets fill:#fce4ec,stroke:#e91e63
    style components fill:#e3f2fd,stroke:#1976d2
    style infra fill:#f3e5f5,stroke:#9c27b0
```

### Minimal Production Values File

Copy this and fill in the `SET THIS` fields:

```yaml
# my-production-values.yaml

global:
  environment: prod
  deploymentMode: self-hosted
  image:
    registry: 'SET THIS'     # e.g., myregistry.example.com/ctx
    tag: 'SET THIS'          # e.g., v1.2.3

ingress:
  host: 'SET THIS'           # e.g., ctx.example.com

deps:
  postgres:
    host: 'SET THIS'         # e.g., postgres.internal
    sslMode: require
  neo4j:
    host: 'SET THIS'         # e.g., neo4j.internal
  temporal:
    address: 'SET THIS'      # e.g., temporal.internal:7233

secrets:
  provider: kubernetes       # pre-create the K8s secret

identity:
  adminAccess:
    mode: private            # or "disabled"

api:
  env:
    CORS_ALLOWED_ORIGINS: 'SET THIS'  # e.g., https://ctx.example.com
```

### All Default Values

See the complete annotated defaults in `deploy/charts/ctx/values.yaml`. Every field has an inline comment explaining its purpose.

### Environment-Specific Overlays

| File | When to Use |
|------|------------|
| `values-production.yaml` | Self-hosted production. HA replicas, network policies, TLS required. |
| `values-staging.yaml` | Pre-production testing. Single replicas, relaxed policies. |
| `values-azure.yaml` | Azure AKS deployment. Pre-configured for Azure services. |
| `values-minikube.yaml` | Local PoC on Minikube. Single replicas, RWO storage, no policies. |

### Quick Helm Commands Reference

```bash
# Install:
helm install ctx ./deploy/charts/ctx -f my-values.yaml -n ctx --wait

# Upgrade:
helm upgrade ctx ./deploy/charts/ctx -f my-values.yaml -n ctx --wait

# Dry-run (preview changes):
helm upgrade ctx ./deploy/charts/ctx -f my-values.yaml -n ctx --dry-run

# Template (render locally):
helm template ctx ./deploy/charts/ctx -f my-values.yaml -n ctx

# Lint (validate chart):
helm lint ./deploy/charts/ctx -f my-values.yaml

# Status:
helm status ctx -n ctx

# History:
helm history ctx -n ctx

# Rollback:
helm rollback ctx <revision> -n ctx

# Uninstall:
helm uninstall ctx -n ctx
# Note: PVCs are NOT deleted by uninstall. Delete manually if needed:
# kubectl delete pvc -n ctx -l app.kubernetes.io/instance=ctx
```

---

**Need help?** Contact your Tabnine account team or file a support ticket.
