# Hera - Kubernetes Cluster Module (Multi-Cloud)

The `kubernetes-cluster` module defines **managed Kubernetes clusters** across multiple cloud providers.

Directory structure:

```
kubernetes-cluster/
├── aws-eks/
├── azure-aks/   (planned)
└── gcp-gke/     (planned)
```

Each provider-specific submodule is responsible for:

- Creating the managed control plane (EKS/AKS/GKE or equivalent)
- Creating or wiring node pools / node groups
- Wiring IAM / RBAC / IRSA-like constructs
- Enabling logging and core addons

This module sits **on top of the network layer** and **depends** on:

- The `bootstrap` module (Terraform backend)
- The `network` module for each cloud (VPC/VNet, subnets, NAT, endpoints)

---

## Purpose

The Kubernetes cluster layer is where **compute capacity** and **scheduling logic** live.

It is also:

- The **largest cost driver** (EC2/VM nodes)
- The primary reliability surface (HA, multi-AZ, autoscaling)
- The foundation for application workloads and platform services

Because of this, it is considered **ephemeral** relative to the bootstrap layer:
- You can destroy **clusters** (especially dev/stage) while keeping:
  - Terraform backend
  - Networking
  - Shared infra (databases, object storage, etc.) intact.

---

## Provider-Specific Implementations

### AWS - `aws-eks`

Implements:

- EKS control plane
- Cluster IAM roles
- Node group IAM roles
- Security groups (cluster and nodes)
- Managed node groups with launch templates
- Core EKS addons (vpc-cni, kube-proxy, coredns)
- Optional:
  - IRSA (OIDC provider)
  - EBS CSI driver
  - Cluster Autoscaler IAM

This is the current reference implementation. Azure and GCP modules should match its capabilities where possible.

---

### Azure - `azure-eks` (Planned)

Will host an AKS-style implementation:

- AKS cluster
- Node pools
- Managed identities / AAD integration
- Logging integration (Azure Monitor)
- CSI drivers and autoscaling setup

### GCP - `gcp-gke` (Planned)

Will host a GKE-based implementation:

- GKE cluster
- Node pools
- Workload Identity (IRSA equivalent)
- Cloud Logging integration
- CSI drivers and autoscaling setup

---

## Cost Positioning

Cluster modules are **more expensive** than bootstrap and network, because:

- You pay for:
  - Managed control plane (EKS/AKS/GKE)
  - Worker nodes / node pools
  - Cluster logging
  - Storage addons

Typical per-environment approximate ranges:

| Layer        | Dev Cost (per month) | Prod Cost (per month) |
|-------------|----------------------|------------------------|
| Bootstrap   | $0.50 - $3           | $0.50 - $3            |
| Network     | $40 - $80            | $120 - $180           |
| Cluster     | $80 - $300+          | $300 - $1000+         |

Numbers depend heavily on:
- Node type and count
- Workload density
- Logging and addons
- Spot / preemptible vs on-demand

---

## Design Goals

- **Cloud-agnostic**: same mental model on AWS/Azure/GCP
- **Production-ready**: security, logging, addons, encryption
- **Ephemeral-friendly**: safe to recreate dev/staging clusters
- **Cost-aware**: minimal defaults for dev, scalable in prod
- **Composable**: clean interface with the network + app layers

---

## Recommended Strategy

### Dev / Early Stage

- Single small cluster per environment (or even a shared dev cluster)
- Minimal node groups (1-2 nodes, small instances)
- SPOT or preemptible instances where tolerable
- Lower log retention
- Optionally destroy nightly or on weekends

### Production

- Separate clusters for production, staging, and maybe perf-test
- Multiple node groups/pools:
  - System / critical workloads on on-demand
  - Batch / non-critical on spot/preemptible
- Control plane logs enabled
- IRSA / Workload Identity used everywhere
- KMS / Key Vault / CMEK-based encryption where applicable
- Autoscaling configured and tested (HPA, Cluster Autoscaler, etc.)

---

## Dependencies and Ordering

1. **Bootstrap** (per cloud)
2. **Network** (per cloud)
3. **Kubernetes Cluster** (this module)
4. **Platform / App layers** (ingress, monitoring, workloads, CI/CD agents, etc.)

Destroy order in reverse, typically:
- Apps → Cluster → Network → (Bootstrap stays)

