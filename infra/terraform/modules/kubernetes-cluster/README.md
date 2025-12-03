# Hera - Kubernetes Cluster Module (Multi-Cloud)

The `kubernetes-cluster` module defines **managed Kubernetes clusters** across multiple cloud providers.

## Implementation Status

```
kubernetes-cluster/
├── aws-eks/     ✅ Production-ready (EKS 1.32, IRSA, managed node groups, addons)
├── azure-aks/   🔄 Planned (AKS with Managed Identities)
└── gcp-gke/     🔄 Planned (GKE with Workload Identity)
```

**Legend:**
- ✅ Fully implemented and production-tested
- 🔄 Stub/planned for future implementation

Each provider-specific submodule is responsible for:

- Creating the managed control plane (EKS/AKS/GKE)
- Creating or wiring node pools / node groups
- Wiring IAM / RBAC / IRSA-like constructs (Workload Identity, Managed Identities)
- Enabling logging and core addons required for a stable cluster

This module sits **on top of the network layer** and **depends** on:

- The `bootstrap` module (Terraform backend)
- The `network` module for each cloud (VPC/VNet, subnets, NAT, endpoints)

---

# Purpose

The Kubernetes cluster layer is where **compute capacity** and **scheduling logic** live.

It is also:

- The **largest cost driver** (EC2/VM nodes)
- The primary reliability surface (HA, multi-AZ, autoscaling)
- The foundation for application workloads and platform services

This layer is considered **ephemeral** relative to `bootstrap` and `network`.  
You can destroy **dev/stage clusters** regularly while keeping:

- Terraform backend
- Networking
- Shared long-lived infra (databases, buckets, secrets stores)

---

# Provider-Specific Implementations

## AWS — `aws-eks`

Implements:

- EKS control plane
- IAM roles for cluster & node groups
- Security groups (cluster and nodes)
- Managed node groups with launch templates
- Core EKS addons (vpc-cni, kube-proxy, coredns)
- Optional:
  - IRSA (OIDC provider)
  - EBS CSI driver
  - Cluster Autoscaler IAM integration

This is the current reference implementation.  
Azure and GCP modules will match capabilities where possible.

---

## Azure — `azure-aks` (Planned)

Will include:

- AKS managed control plane
- Node pools
- Managed Identities + Azure AD integration
- Cluster logging via Azure Monitor
- CSI drivers and autoscaling setup

---

## GCP — `gcp-gke` (Planned)

Will include:

- GKE control plane
- Node pools
- Workload Identity (GCP equivalent of IRSA)
- Cloud Logging integration
- CSI drivers and autoscaling setup

---

# Cost Positioning

Cluster modules are **more expensive** than bootstrap and network, because cloud providers charge for:

- Control plane hours (EKS/GKE)
- Worker nodes / node pools
- Cluster logging
- CSI drivers & storage usage

Typical per-environment ranges:

| Layer        | Dev Cost (per month) | Prod Cost (per month) |
|--------------|------------------------|-------------------------|
| Bootstrap    | $0.50 - $3             | $0.50 - $3              |
| Network      | $40 - $80              | $120 - $180             |
| Cluster      | $80 - $300+            | $300 - $1000+           |

Final numbers depend on:

- Node size & count
- Autoscaling settings
- Spot / preemptible usage
- Logging retention
- Storage consumption

---

# Design Goals

- **Cloud-agnostic**: Same expectations on AWS, Azure, and GCP  
- **Production-ready**: secure defaults, IRSA/Workload Identity, encryption  
- **Ephemeral-friendly**: Dev/stage clusters can be recreated daily  
- **Cost-aware**: minimal defaults for development environments  
- **Composable**: clean interface with network and application layers  

---

# Recommended Strategy

## Dev / Early Stage

- One small cluster per environment (or a shared dev cluster)
- 1-2 small nodes
- Spot / preemptible nodes where possible
- Lower log retention
- Optional nightly teardown + morning re-creation  
  (major monthly savings)

## Production

- Dedicated clusters (prod, staging, perf)
- Multiple node groups/pools:
  - on-demand for system workloads
  - spot/preemptible for non-critical workloads
- Full IRSA / Workload Identity
- Control plane logs enabled
- KMS / Key Vault / CMEK encryption
- Horizontal Pod Autoscaler + Cluster Autoscaler  
- Observability stack (metrics, logs, alerts)

---

# Dependencies and Ordering

Provisioning order:

1. **Bootstrap** (persistent state + backend)
2. **Network** (VPC/VNet + subnets)
3. **Kubernetes Cluster** (this module)
4. **Platform Layer**:
   - Ingress (ALB/Nginx)
   - Metrics Server
   - Cert Manager
   - External DNS
   - Autoscaler
   - Monitoring/logging stack
5. **Applications**

Destroy order is typically reversed:
Apps → Platform → Cluster → Network  
(Bootstrap always stays)

---

# After the Cluster is Created — Initial Usage (Day-1 Guide)

These steps apply to **all clouds**, with cloud-specific commands where needed.

The cluster is now provisioned — this is how you begin using it.

---

## 1. Configure `kubectl` (cloud-specific)

### **AWS**
```
aws eks update-kubeconfig --region <region> --name <cluster_name>
```

### **Azure**
```
az aks get-credentials --resource-group <rg> --name <cluster_name>
```

### **GCP**
```
gcloud container clusters get-credentials <cluster_name> --region <region>
```

Verify:
```
kubectl get nodes
```

---

## 2. Verify Core System Pods

Across all clouds you expect:

- `coredns-*`
- `kube-proxy-*`
- CNI plugin for networking:
  - AWS: `aws-node-*`
  - Azure: `azure-cni-*` or `calico-*`
  - GCP: `gke-metrics-agent`, `gke-netd`, etc.

Check:
```
kubectl get pods -n kube-system
```

---

## 3. Install Core Platform Addons (Recommended)

These addons are **cloud-agnostic** functionally but have cloud-specific backends.

### **Metrics Server**  
Required for HPA, scaling, dashboards:
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

### **Ingress Controller**

- AWS: ALB Ingress Controller  
- Azure: AGIC or Nginx  
- GCP: GCE Ingress Controller or Nginx

---

### **Cert Manager** (TLS automation)
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

---

### **External DNS**
Manages DNS records automatically based on Ingress resources.

---

### **Cluster Autoscaler**
Cloud-specific but always required on production workloads.

---

## 4. Prepare Namespaces & RBAC

Minimal setup:
```
kubectl create namespace apps
kubectl create namespace infra
kubectl create namespace monitoring
```

Set default:
```
kubectl config set-context --current --namespace=apps
```

---

## 5. Install Observability

Choose based on stack:

- Prometheus / Mimir  
- Grafana  
- Loki / CloudWatch / Stackdriver / Azure Monitor  
- Alertmanager  
- FluentBit / FluentD  

This layer is part of **Platform**, not the cluster itself.

---

## 6. Deploy Applications

Once the platform basics exist:

- Apply manifests:
  ```
  kubectl apply -f deployment/
  ```

- Or use:
  - Helm
  - ArgoCD
  - FluxCD
  - Skaffold
  - Custom CI/CD pipelines

---

# Summary

This module provides the **managed Kubernetes control plane** across clouds.  
Once created, the **initial usage steps** in this README guide you through connecting your CLI,
verifying health, installing core platform services, and deploying workloads.

This structure ensures:

- Multi-cloud symmetry  
- Predictable Day-0 → Day-1 experience  
- Cost awareness and flexibility  
- Production readiness  

