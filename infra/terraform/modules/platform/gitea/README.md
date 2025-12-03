# Gitea Module

## Overview

This module deploys [Gitea](https://gitea.io/), a lightweight self-hosted Git service, into your Kubernetes cluster. Gitea provides a Git repository hosting platform similar to GitHub, but running entirely within your infrastructure.

## What is Gitea?

Gitea is a painless self-hosted Git service written in Go. It's designed to be:
- **Lightweight**: Minimal resource requirements
- **Fast**: Optimized for performance
- **Easy to deploy**: Simple installation and configuration
- **Feature-rich**: Web UI, API, webhooks, organization support

## Use Cases

### Development Environments
- **In-cluster Git server** for fast iteration without external dependencies
- **Offline development** without requiring internet connectivity
- **Cost-effective** alternative to hosted Git services for dev/test

### General Purpose
- **Private Git hosting** within your infrastructure
- **Git backend** for CI/CD tools, configuration management
- **Team collaboration** on internal projects
- **Git repository** for Kubernetes manifests, IaC code, documentation

### CI/CD Integration
- Source repository for GitOps tools (ArgoCD, Flux, etc.)
- Webhook integration with CI systems
- Git storage for Helm charts or OCI artifacts

## Features

- ✅ **Web UI**: User-friendly interface for Git repository management
- ✅ **RESTful API**: Full API for automation and integration
- ✅ **Organizations & Teams**: Multi-user collaboration support
- ✅ **Webhooks**: Integration with external services
- ✅ **PostgreSQL Backend**: Reliable database for metadata
- ✅ **Persistent Storage**: Data persisted across pod restarts
- ✅ **Auto-generated Passwords**: Secure random admin password
- ✅ **In-cluster Access**: ClusterIP service for internal use

## Architecture

```
┌─────────────────────────────────────────┐
│          Kubernetes Cluster              │
├─────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────┐    │
│  │  Gitea Pod                     │    │
│  │  ┌──────────────────────────┐  │    │
│  │  │  Gitea Application       │  │    │
│  │  │  (Go Binary)             │  │    │
│  │  │  - Web UI                │  │    │
│  │  │  - Git SSH/HTTP          │  │    │
│  │  │  - API Server            │  │    │
│  │  └──────────────────────────┘  │    │
│  └────────────────────────────────┘    │
│              │                          │
│              │ connects to              │
│              ▼                          │
│  ┌────────────────────────────────┐    │
│  │  PostgreSQL Pod                │    │
│  │  - Metadata storage            │    │
│  │  - User accounts               │    │
│  │  - Repository metadata         │    │
│  └────────────────────────────────┘    │
│              │                          │
│              ▼                          │
│  ┌────────────────────────────────┐    │
│  │  Persistent Volumes            │    │
│  │  - Git repositories (10Gi)     │    │
│  │  - PostgreSQL data (5Gi)       │    │
│  └────────────────────────────────┘    │
│                                          │
│  Service: gitea-http.namespace:3000     │
│  (ClusterIP - internal access only)     │
└─────────────────────────────────────────┘
```

## Usage

### Basic Deployment

```hcl
module "gitea" {
  source = "../../../modules/platform/gitea"

  cluster_name     = "my-cluster"
  namespace        = "git"
  create_namespace = true
  admin_username   = "git-admin"
  admin_email      = "admin@example.com"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

### With Custom Configuration

```hcl
module "gitea" {
  source = "../../../modules/platform/gitea"

  cluster_name     = "my-cluster"
  namespace        = "git"
  create_namespace = true
  admin_username   = "git-admin"
  admin_email      = "admin@example.com"

  # Custom Helm values
  values = yamlencode({
    persistence = {
      enabled      = true
      size         = "50Gi"  # Larger storage
      storageClass = "gp3"
    }
    postgresql = {
      persistence = {
        size = "20Gi"
      }
    }
    resources = {
      requests = {
        cpu    = "200m"
        memory = "512Mi"
      }
      limits = {
        cpu    = "1000m"
        memory = "1Gi"
      }
    }
    # Optional: Enable ingress for external access
    ingress = {
      enabled   = true
      className = "alb"
      hosts = [{
        host = "git.dev.example.com"
        paths = [{
          path     = "/"
          pathType = "Prefix"
        }]
      }]
    }
  })

  tags = local.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cluster_name` | Name of the Kubernetes cluster | `string` | - | yes |
| `namespace` | Kubernetes namespace for Gitea | `string` | `"git"` | no |
| `create_namespace` | Create the namespace if it doesn't exist | `bool` | `false` | no |
| `admin_username` | Gitea admin username | `string` | `"gitea-admin"` | no |
| `admin_password` | Gitea admin password (leave empty to auto-generate) | `string` | `""` | no |
| `admin_email` | Gitea admin email | `string` | `"admin@gitea.local"` | no |
| `chart_version` | Gitea Helm chart version | `string` | `"10.1.4"` | no |
| `values` | Additional values to pass to Gitea Helm chart (YAML string) | `string` | `""` | no |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `namespace` | Kubernetes namespace where Gitea is deployed |
| `admin_username` | Gitea admin username |
| `admin_password` | Gitea admin password (sensitive) |
| `service_url` | Gitea in-cluster service URL |
| `service_name` | Gitea HTTP service name |
| `kubectl_port_forward` | kubectl command to access Gitea UI |

## Post-Deployment

### Accessing Gitea

```bash
# Get admin credentials
GITEA_USERNAME=$(terraform output -raw gitea_admin_username)
GITEA_PASSWORD=$(terraform output -raw gitea_admin_password)

# Port-forward to access UI
kubectl port-forward -n <namespace> svc/gitea-http 3000:3000

# Open browser: http://localhost:3000
# Login with: $GITEA_USERNAME / $GITEA_PASSWORD
```

### Creating a Repository

**Via Web UI**:
1. Login to Gitea UI
2. Click "+" → "New Repository"
3. Enter repository name and settings
4. Click "Create Repository"

**Via API**:
```bash
curl -X POST http://localhost:3000/api/v1/user/repos \
  -H "Content-Type: application/json" \
  -u gitea-admin:$GITEA_PASSWORD \
  -d '{
    "name": "my-repo",
    "description": "My repository",
    "private": false
  }'
```

### Cloning a Repository

```bash
# Clone via HTTP (requires port-forward)
git clone http://localhost:3000/gitea-admin/my-repo.git

# Or use in-cluster service URL (from within cluster)
git clone http://gitea-http.<namespace>.svc.cluster.local:3000/gitea-admin/my-repo.git
```

### Creating Organizations and Teams

1. Login to Gitea UI
2. Click "+" → "New Organization"
3. Create teams within organization
4. Add members to teams
5. Assign repository permissions to teams

## Cost Considerations

### Development Environment

| Component | Configuration | Monthly Cost (us-east-1) |
|-----------|---------------|-------------------------|
| Gitea Pod | 1 replica: 100m CPU, 256Mi RAM | ~$4 |
| PostgreSQL | 1 instance: 100m CPU, 256Mi RAM | ~$4 |
| Storage | 15Gi EBS gp3 (10Gi repos + 5Gi DB) | ~$1.20 |
| **Total** | | **~$9.20/month** |

**Cost Optimization for Dev:**
- **Nightly teardown**: Destroy dev clusters overnight → ~$0.40/day × 22 days = **$8.80/month**
- **Smaller storage**: Use 5Gi total for dev → Save $0.40/month
- **Spot instances**: Run on spot nodes → Save ~30%

---

### Production Environment (High Availability)

| Component | Configuration | Monthly Cost (us-east-1) |
|-----------|---------------|-------------------------|
| Gitea Pods | 2 replicas: 500m CPU, 1Gi RAM each | ~$30 |
| PostgreSQL HA | Primary + replica: 500m CPU, 1Gi RAM each | ~$30 |
| Storage | 70Gi EBS gp3 (50Gi repos + 20Gi DB) | ~$5.60 |
| **Subtotal** | Internal access only | **~$65.60/month** |
| **Optional: ALB** | External access via Application Load Balancer | **+$16/month** |
| **Total with ALB** | | **~$81.60/month** |

**Production Configuration Example:**

```hcl
module "gitea" {
  source = "../../../modules/platform/gitea"

  cluster_name     = var.cluster_name
  namespace        = "git"
  create_namespace = true

  values = yamlencode({
    # High availability: 2 replicas
    replicaCount = 2

    persistence = {
      enabled      = true
      size         = "50Gi"
      storageClass = "gp3"
    }

    # PostgreSQL HA
    postgresql = {
      enabled = true
      primary = {
        persistence = {
          size = "20Gi"
        }
      }
      readReplicas = {
        replicaCount = 1
        persistence = {
          size = "20Gi"
        }
      }
    }

    # Production resources
    resources = {
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
      limits = {
        cpu    = "2000m"
        memory = "2Gi"
      }
    }

    # External access (optional)
    ingress = {
      enabled   = true
      className = "alb"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"     = "ip"
        "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":443}]"
        "alb.ingress.kubernetes.io/certificate-arn" = var.acm_certificate_arn
      }
      hosts = [{
        host = "git.example.com"
        paths = [{
          path     = "/"
          pathType = "Prefix"
        }]
      }]
    }

    # Monitoring (optional)
    metrics = {
      enabled = true
      serviceMonitor = {
        enabled = true
      }
    }
  })

  tags = local.tags
}
```

---

### Cost Comparison: Gitea vs External Git

| Aspect | Gitea (Self-Hosted) | GitHub Enterprise | GitLab Ultimate |
|--------|---------------------|-------------------|-----------------|
| **Monthly Cost** | ~$65-86 (HA) | $21/user/month | $99/user/month |
| **Infrastructure** | You manage | GitHub manages | GitLab manages |
| **Backup/DR** | You configure | Included | Included |
| **SLA** | Your responsibility | 99.9% uptime | 99.95% uptime |
| **Support** | Community | Enterprise support | Enterprise support |
| **Compliance** | DIY | SOC 2, ISO 27001 | SOC 2, ISO 27001 |
| **Scaling** | Manual | Automatic | Automatic |

**When to Use Gitea in Production:**

✅ **Good Fit:**
- Strict data sovereignty requirements (data must stay in your infrastructure)
- Air-gapped or highly restricted environments (no external internet access)
- Small team (1-10 users) where per-user pricing of GitHub/GitLab is expensive
- Existing Gitea expertise and operational capability
- Need full control over Git infrastructure and customization

⚠️ **Consider External Git (GitHub/GitLab) If:**
- Team size >10 users (per-user cost becomes competitive)
- Need enterprise features (advanced audit logs, compliance certifications)
- Want zero ops overhead (no management, patching, backup responsibility)
- Need guaranteed SLA (99.9%+ uptime)
- Team already familiar with GitHub/GitLab workflows
- Need integration ecosystem (GitHub Actions, GitLab CI, third-party apps)

### Total Platform Costs

**Dev Environment (Gitea + ArgoCD):**
- Gitea: $9/month
- ArgoCD: $19/month
- **Combined: ~$28/month**

**Prod Environment (Gitea HA + ArgoCD HA):**
- Gitea: $65-86/month
- ArgoCD: $324/month
- **Combined: ~$389-410/month**

**Prod with External Git (GitHub + ArgoCD HA):**
- Gitea: $0 (not deployed)
- ArgoCD: $324/month
- GitHub Enterprise: $21/user/month (separate subscription)
- **Platform Cost: ~$324/month** (+ GitHub subscription)

## Day 1 Quick Start

### Prerequisites

- Kubernetes cluster (EKS, AKS, GKE, etc.)
- kubectl configured
- Terraform >= 1.6.0
- Helm provider configured

### Deploy

```bash
# 1. Add module to your environment
# (See usage examples above)

# 2. Initialize and apply
terraform init
terraform plan
terraform apply

# 3. Access Gitea
kubectl port-forward -n git svc/gitea-http 3000:3000

# 4. Login
# URL: http://localhost:3000
# Username: gitea-admin
# Password: $(terraform output -raw gitea_admin_password)

# 5. Create your first repository
# Use web UI or API
```

## Troubleshooting

### Pod Not Starting

**Symptom**: Gitea pod stuck in `Pending` or `CrashLoopBackOff`

```bash
# Check pod status
kubectl get pods -n <namespace> -l app.kubernetes.io/name=gitea

# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>
```

**Common Causes**:
- Insufficient cluster resources
- Storage class not available (`kubectl get sc`)
- PostgreSQL not ready

### Can't Access Gitea UI

**Symptom**: Port-forward works but can't login

```bash
# Verify service exists
kubectl get svc -n <namespace> gitea-http

# Test connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n <namespace> -- \
  curl -v http://gitea-http:3000

# Check Gitea logs
kubectl logs -n <namespace> -l app.kubernetes.io/name=gitea
```

### Database Connection Errors

**Symptom**: Gitea logs show PostgreSQL connection failures

```bash
# Check PostgreSQL pod
kubectl get pods -n <namespace> -l app.kubernetes.io/name=postgresql

# Check PostgreSQL logs
kubectl logs -n <namespace> -l app.kubernetes.io/name=postgresql

# Restart Gitea pod
kubectl rollout restart deployment/gitea -n <namespace>
```

### Forgot Admin Password

```bash
# Get password from Terraform output
terraform output -raw gitea_admin_password

# Or reset by deleting and redeploying
terraform destroy -target=module.gitea
terraform apply
```

## Integration Examples

### Using Gitea as Git Backend for Other Tools

Once Gitea is deployed, you can use it as a Git backend for:

**In-cluster tools** (use service URL):
```
http://gitea-http.<namespace>.svc.cluster.local:3000/user/repo.git
```

**External tools** (requires ingress or port-forward):
```
http://localhost:3000/user/repo.git  # via port-forward
https://git.example.com/user/repo.git  # via ingress
```

### API Integration

```bash
# Get repository list
curl -u gitea-admin:$PASSWORD http://localhost:3000/api/v1/user/repos

# Create webhook
curl -X POST http://localhost:3000/api/v1/repos/gitea-admin/my-repo/hooks \
  -H "Content-Type: application/json" \
  -u gitea-admin:$PASSWORD \
  -d '{
    "type": "gitea",
    "config": {
      "url": "http://ci-server:8080/webhook",
      "content_type": "json"
    },
    "events": ["push"],
    "active": true
  }'
```

## Security Best Practices

1. **Don't commit passwords**: Use Terraform outputs or secrets management
2. **Use namespaces**: Isolate Gitea from other workloads
3. **Network policies**: Restrict access to Gitea service
4. **Regular backups**: Backup persistent volumes
5. **Update regularly**: Keep Gitea version current

## References

- [Gitea Official Documentation](https://docs.gitea.io/)
- [Gitea Helm Chart](https://gitea.com/gitea/helm-chart)
- [Gitea API Documentation](https://docs.gitea.io/en-us/api-usage/)
