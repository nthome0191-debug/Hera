# Hera - Platform Modules

Platform modules contain standalone, reusable platform components that run on Kubernetes clusters. Each module is independent and can be composed at the environment level.

## Implementation Status

```
platform/
├── gitea/             ✅ Production-ready (in-cluster Git server)
├── argocd/            ✅ Production-ready (GitOps continuous delivery)
├── monitoring/        🔄 Planned (Prometheus + Grafana + Loki)
├── ingress/           🔄 Planned (NGINX/ALB ingress controllers)
├── cert-manager/      🔄 Planned (TLS certificate management)
├── external-secrets/  🔄 Planned (External secrets integration)
├── service-mesh/      🔄 Planned (Istio/Linkerd)
└── security/          🔄 Planned (Falco, OPA, policy enforcement)
```

**Legend:**
- ✅ Fully implemented and production-ready
- 🔄 Planned for future implementation

## Module Details

### Gitea (✅ Production-Ready)

**Purpose:** Lightweight self-hosted Git service

**What It Is:**
- Standalone in-cluster Git server (like GitHub, but self-hosted)
- No dependencies on other modules
- Can be used independently for any Git needs

**Key Features:**
- Web UI for repository management
- RESTful API for automation
- Organizations and teams support
- Webhooks integration
- PostgreSQL backend
- Persistent storage

**Use Cases:**
- **Development Git**: In-cluster Git for dev environments (no external dependencies)
- **Git Backend for Tools**: Git storage for ArgoCD, CI/CD, config management
- **Team Collaboration**: Internal Git hosting for private projects
- **Offline Development**: Git access without internet connectivity

**Namespace:** `git` (default, configurable)

**Resources:**
- Dev: ~$9/month (single replica, minimal resources, 15Gi storage)
- Prod: ~$65-86/month (HA with 2 replicas, 70Gi storage, optional ALB)

**When to Use in Production:**
- ✅ Strict data sovereignty requirements
- ✅ Air-gapped environments
- ✅ Full control over Git infrastructure
- ⚠️ Consider GitHub/GitLab for enterprise features, managed backups, SLA guarantees

**Documentation:** [gitea/README.md](gitea/README.md)

---

### ArgoCD (✅ Production-Ready)

**Purpose:** GitOps continuous delivery for Kubernetes

**What It Is:**
- Kubernetes-native CD tool that syncs Git → Kubernetes
- Works with **any Git backend** (GitHub, GitLab, Bitbucket, Gitea, self-hosted)
- No coupling to specific Git providers

**Key Features:**
- Git as source of truth for application definitions
- Automated sync from Git to Kubernetes
- Multi-cluster support
- Web UI + CLI
- SSO integration (OIDC, SAML, OAuth2)
- RBAC for team access
- Health monitoring and rollback

**Git Backend Options:**
- ✅ GitHub (production standard)
- ✅ GitLab (production standard)
- ✅ Bitbucket
- ✅ In-cluster Gitea (dev environments)
- ✅ Self-hosted Git

**Namespace:** `argocd` (default, configurable)

**Resources:**
- Dev: ~$19/month (single replica, minimal resources)
- Prod: ~$324/month (HA with 3 replicas, Redis HA)

**Documentation:** [argocd/README.md](argocd/README.md)

---

### Monitoring (🔄 Planned)

**Purpose:** Observability stack for metrics, logs, and traces

**Planned Components:**
- Prometheus for metrics collection
- Grafana for visualization
- Loki for log aggregation
- Alertmanager for alert routing
- Jaeger/Tempo for distributed tracing

---

### Ingress (🔄 Planned)

**Purpose:** HTTP/HTTPS traffic routing

**Planned Options:**
- NGINX Ingress Controller (cloud-agnostic)
- AWS ALB Ingress Controller (EKS-specific)
- Azure Application Gateway (AKS-specific)
- GCP Ingress (GKE-specific)

---

## Deployment Patterns

Platform modules are deployed **after** the Kubernetes cluster exists:

```
1. Bootstrap (S3/DynamoDB for state)
   ↓
2. Network (VPC/VNet)
   ↓
3. Kubernetes Cluster (EKS/AKS/GKE)
   ↓
4. Platform Layer ← You are here
   │
   ├─ Gitea (optional, typically dev only)
   ├─ ArgoCD (connects to Gitea or external Git)
   ├─ Monitoring (optional)
   └─ Ingress (optional)
   ↓
5. Applications (deployed via ArgoCD)
```

## Module Comparison

| Aspect | Gitea | ArgoCD |
|--------|-------|--------|
| **Purpose** | Git server | GitOps CD |
| **Depends On** | None | Any Git backend |
| **Namespace** | `git` (default) | `argocd` (default) |
| **Dev Cost** | ~$9/month | ~$19/month |
| **Prod Cost** | ~$65-86/month (HA) | ~$324/month (HA) |
| **Standalone?** | ✅ Yes | ✅ Yes (with external Git) |
| **Environment Awareness** | ❌ No | ❌ No |
| **Git Backends** | N/A (is a Git backend) | GitHub, GitLab, Bitbucket, Gitea, self-hosted |
| **Typical Prod Usage** | Rare (usually GitHub/GitLab) | Standard |

## Getting Started

### Quick Start: Dev Environment

```bash
# 1. Deploy infrastructure
cd infra/terraform/envs/dev/aws
terraform apply

# 2. Access Gitea
kubectl port-forward -n git svc/gitea-http 3000:3000
# Open: http://localhost:3000
# Login: gitea-admin / $(terraform output -raw gitea_admin_password)

# 3. Create repository "gitops-repo" in Gitea

# 4. Access ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8080:443
# Open: https://localhost:8080
# Login: admin / $(terraform output -raw argocd_admin_password)

# 5. Deploy applications via ArgoCD UI or CLI
```

### Quick Start: Prod Environment

```bash
# 1. Prerequisites
# - Create GitHub repository "gitops-repo"
# - Create GitHub PAT with repo scope
# - Store token in AWS Secrets Manager

# 2. Deploy infrastructure
cd infra/terraform/envs/prod/aws
terraform apply

# 3. Access ArgoCD
# Open: https://argocd.example.com
# Login: admin / $(terraform output -raw argocd_admin_password)

# 4. Deploy applications via ArgoCD
```

## Communication Between Modules

Services communicate via **Kubernetes DNS** across namespaces:

```
ArgoCD (namespace: argocd)
    ↓
    Connects via DNS:
    ↓
http://gitea-http.git.svc.cluster.local:3000
                   ↑
              namespace!
```

**DNS Pattern**: `<service>.<namespace>.svc.cluster.local:<port>`

## Design Patterns

### ✅ Correct: Composition at Environment Level

```hcl
# envs/dev/aws/main.tf
module "gitea" { ... }
module "argocd" {
  git_repository_url = module.gitea.service_url  # ← Connection here
}
```

### ❌ Incorrect: Module-Level Coupling

```hcl
# modules/platform/argocd/main.tf
module "gitea" { ... }  # ❌ Don't embed other modules
```

### ✅ Correct: Modules Accept Inputs

```hcl
# ArgoCD module accepts ANY Git URL
git_repository_url = "https://github.com/..."      # GitHub
git_repository_url = "https://gitlab.com/..."      # GitLab
git_repository_url = module.gitea.service_url      # Gitea
```

### ❌ Incorrect: Modules Detect Environment

```hcl
# ❌ Don't do this in modules:
locals {
  is_dev = var.environment == "dev"
  git_backend = local.is_dev ? "gitea" : "github"
}
```

## Roadmap

### Q1 2025
- ✅ Gitea module (standalone Git server)
- ✅ ArgoCD module (GitOps CD, Git-agnostic)
- 🔄 Monitoring module (Prometheus + Grafana)
- 🔄 Ingress module (NGINX)

### Q2 2025
- 🔄 Cert Manager module
- 🔄 External Secrets module
- 🔄 Service Mesh module (Istio/Linkerd)

### Q3 2025
- 🔄 Security module (Falco, OPA)
- 🔄 CI module (Argo Workflows or Tekton)

## Contributing

When adding new platform modules:

1. **Follow separation principles**:
   - Module = standalone provisioning logic only
   - No environment detection inside modules
   - No coupling to other modules

2. **Include comprehensive README**:
   - What the module does (standalone description)
   - How to use it independently
   - How to compose it with other modules (show examples)
   - Architecture diagrams
   - Cost analysis
   - Troubleshooting guide

3. **Provide examples**:
   - Show standalone usage
   - Show composition patterns
   - Dev and prod configurations

4. **Test independence**:
   - Module should work alone
   - Module should work with any compatible dependencies
   - No hard-coded assumptions about other modules

## References

- [Gitea Module Documentation](gitea/README.md)
- [ArgoCD Module Documentation](argocd/README.md)
- [Hera Architecture Guide](../../../README.md)
- [Environment Compositions](../../envs/)
