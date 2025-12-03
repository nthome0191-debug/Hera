# ArgoCD Module

## Overview

This module deploys [ArgoCD](https://argo-cd.readthedocs.io/), a declarative GitOps continuous delivery tool for Kubernetes. ArgoCD automates application deployment by continuously monitoring Git repositories and synchronizing the desired state with your Kubernetes clusters.

## What is ArgoCD?

ArgoCD is a Kubernetes-native continuous deployment tool that:
- **Monitors Git repositories** for changes to application manifests
- **Automatically syncs** desired state from Git to Kubernetes
- **Provides visibility** into application health and sync status
- **Enables rollback** to any previous Git commit
- **Supports multiple** deployment strategies (rolling, blue-green, canary)

## Key Concepts

**GitOps Workflow**:
```
Developer → Git Push → Git Repository → ArgoCD → Kubernetes Cluster
                           ↓                ↓
                    (Source of Truth)  (Continuous Sync)
```

## Features

- ✅ **Git as Source of Truth**: Declarative application definitions in Git
- ✅ **Automated Sync**: Continuously monitors and synchronizes applications
- ✅ **Multi-cluster Support**: Manage deployments across multiple clusters
- ✅ **Web UI + CLI**: Powerful interfaces for managing deployments
- ✅ **SSO Integration**: Enterprise authentication (OIDC, SAML, OAuth2)
- ✅ **RBAC**: Fine-grained access control
- ✅ **Webhooks**: Integration with Git providers
- ✅ **Health Assessment**: Real-time application health monitoring
- ✅ **Rollback**: Easy rollback to any previous state

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   ArgoCD Components                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────┐ │
│  │   ArgoCD UI  │    │  ArgoCD API  │    │   CLI    │ │
│  │   (Server)   │───▶│    Server    │◀───│  Client  │ │
│  └──────────────┘    └──────┬───────┘    └──────────┘ │
│                             │                           │
│                 ┌───────────┴───────────┐              │
│                 │                       │              │
│         ┌───────▼────────┐     ┌───────▼────────┐     │
│         │  Repo Server   │     │   Controller   │     │
│         │ (Git Watcher)  │     │ (Sync Engine)  │     │
│         └───────┬────────┘     └───────┬────────┘     │
│                 │                      │              │
└─────────────────┼──────────────────────┼──────────────┘
                  │                      │
         ┌────────▼────────┐    ┌────────▼────────┐
         │  Git Repository │    │  Kubernetes API │
         │  (Any Backend)  │    │  (Target State) │
         │                 │    │                 │
         │  • GitHub       │    └─────────────────┘
         │  • GitLab       │
         │  • Bitbucket    │
         │  • Gitea        │
         │  • Self-hosted  │
         └─────────────────┘
```

## Usage

### Basic Deployment

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = "my-cluster"
  namespace    = "argocd"

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### With Git Repository Configuration

ArgoCD can connect to **any Git backend**. Configure the Git repository after deployment:

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = "my-cluster"
  namespace    = "argocd"

  # Configure Git repository (optional - can also be done via UI/CLI)
  git_repository_url      = "https://github.com/your-org/gitops-repo"
  git_repository_username = "github-username"
  git_repository_password = var.github_token  # PAT or app token

  tags = local.tags
}
```

### Production HA Configuration

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = "my-cluster"
  namespace    = "argocd"

  # Production-grade configuration
  values = yamlencode({
    global = {
      domain = "argocd.example.com"
    }

    # High availability: 3 replicas
    server = {
      replicas = 3
      resources = {
        requests = { cpu = "500m", memory = "512Mi" }
        limits   = { cpu = "1000m", memory = "1Gi" }
      }
      ingress = {
        enabled          = true
        ingressClassName = "alb"
        hosts            = ["argocd.example.com"]
        tls = [{
          secretName = "argocd-tls"
          hosts      = ["argocd.example.com"]
        }]
      }
      metrics = {
        enabled = true
        serviceMonitor = { enabled = true }
      }
    }

    repoServer = {
      replicas = 3
      resources = {
        requests = { cpu = "500m", memory = "1Gi" }
        limits   = { cpu = "1000m", memory = "2Gi" }
      }
    }

    controller = {
      replicas = 3
      resources = {
        requests = { cpu = "1000m", memory = "2Gi" }
        limits   = { cpu = "2000m", memory = "4Gi" }
      }
    }

    # Redis HA for production
    redis-ha = {
      enabled  = true
      replicas = 3
    }
    redis = {
      enabled = false  # Using redis-ha instead
    }

    # Enable ApplicationSet for multi-cluster
    applicationSet = {
      enabled  = true
      replicas = 2
    }

    # Enable notifications
    notifications = {
      enabled = true
    }
  })

  tags = local.tags
}
```

## Git Backend Configuration

ArgoCD works with **any Git provider**. Here are common configurations:

### GitHub

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://github.com/your-org/gitops-repo"
  git_repository_username = "github-username"
  git_repository_password = var.github_token  # Personal Access Token

  tags = local.tags
}
```

**GitHub Token Requirements**:
- Settings → Developer settings → Personal access tokens
- Required scopes: `repo` (full control of private repositories)

### GitLab

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://gitlab.com/your-org/gitops-repo"
  git_repository_username = "gitlab-username"
  git_repository_password = var.gitlab_token  # Personal or Project Access Token

  tags = local.tags
}
```

**GitLab Token Requirements**:
- Settings → Access Tokens
- Required scopes: `read_repository`, `write_repository`

### Bitbucket

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://bitbucket.org/your-org/gitops-repo"
  git_repository_username = "bitbucket-username"
  git_repository_password = var.bitbucket_app_password

  tags = local.tags
}
```

### In-Cluster Git (Gitea)

If you deployed Gitea in the same cluster:

```hcl
# First, deploy Gitea module in its own namespace
module "gitea" {
  source = "../../../modules/platform/gitea"

  cluster_name     = var.cluster_name
  namespace        = "git"  # Separate namespace for isolation
  create_namespace = true
  admin_username   = "gitea-admin"
  admin_email      = "admin@dev.local"
}

# Then, deploy ArgoCD in its own namespace
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name     = var.cluster_name
  namespace        = "argocd"  # Separate namespace
  create_namespace = true

  # Use Gitea outputs to configure connection
  # Kubernetes DNS allows cross-namespace communication
  git_repository_url      = "${module.gitea.service_url}/gitea-admin/gitops-repo"
  git_repository_username = module.gitea.admin_username
  git_repository_password = module.gitea.admin_password

  tags       = local.tags
  depends_on = [module.gitea]
}
```

**Important Notes**:
- Each service gets its own namespace for isolation, security, and lifecycle management
- Services communicate via Kubernetes DNS: `service.namespace.svc.cluster.local`
- Gitea service URL will be: `http://gitea-http.git.svc.cluster.local:3000`
- Create the repository in Gitea first, then apply this configuration

### Self-Hosted Git

```hcl
module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://git.yourcompany.com/repo/gitops.git"
  git_repository_username = "git-user"
  git_repository_password = var.git_token

  tags = local.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `cluster_name` | Name of the Kubernetes cluster | `string` | - | yes |
| `namespace` | Kubernetes namespace for ArgoCD | `string` | `"argocd"` | no |
| `create_namespace` | Create the namespace if it doesn't exist | `bool` | `false` | no |
| `chart_version` | ArgoCD Helm chart version | `string` | `"5.51.6"` | no |
| `values` | Values to pass to ArgoCD Helm chart (YAML string) | `string` | `""` | no |
| `admin_password` | ArgoCD admin password (leave empty to auto-generate) | `string` | `""` | no |
| `git_repository_url` | Git repository URL to configure in ArgoCD | `string` | `""` | no |
| `git_repository_username` | Git repository username | `string` | `""` | no |
| `git_repository_password` | Git repository password or token | `string` | `""` | no |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `namespace` | Kubernetes namespace where ArgoCD is deployed |
| `admin_password` | ArgoCD admin password (sensitive) |
| `server_service` | ArgoCD server service name |
| `kubectl_port_forward` | kubectl command to access ArgoCD UI |

## Post-Deployment

### Accessing ArgoCD UI

```bash
# Get admin password
ARGOCD_PASSWORD=$(terraform output -raw argocd_admin_password)

# Port-forward to access UI
kubectl port-forward -n argocd svc/argocd-server 8080:443

# Open browser: https://localhost:8080
# Login: admin / $ARGOCD_PASSWORD
```

### ArgoCD CLI

```bash
# Install ArgoCD CLI
brew install argocd  # macOS
# Or download from: https://github.com/argoproj/argo-cd/releases

# Login
argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

# Add Git repository
argocd repo add https://github.com/your-org/gitops-repo \
  --username github-user \
  --password $GITHUB_TOKEN

# Create application
argocd app create my-app \
  --repo https://github.com/your-org/gitops-repo \
  --path apps/my-app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Sync application
argocd app sync my-app

# Watch sync status
argocd app get my-app --watch
```

### Creating Your First Application

1. **Prepare Git repository** with Kubernetes manifests:
   ```
   gitops-repo/
   ├── apps/
   │   └── nginx/
   │       ├── deployment.yaml
   │       └── service.yaml
   ```

2. **Create ArgoCD application**:
   ```bash
   argocd app create nginx \
     --repo https://github.com/your-org/gitops-repo \
     --path apps/nginx \
     --dest-server https://kubernetes.default.svc \
     --dest-namespace default \
     --sync-policy automated
   ```

3. **Watch deployment**:
   ```bash
   argocd app get nginx
   kubectl get pods -n default -w
   ```

## Common Patterns

### App of Apps Pattern

Manage multiple applications with a single root application:

```yaml
# gitops-repo/root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/gitops-repo
    targetRevision: main
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Environment Overlays (Kustomize)

```
gitops-repo/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patches/
    ├── staging/
    │   ├── kustomization.yaml
    │   └── patches/
    └── prod/
        ├── kustomization.yaml
        └── patches/
```

### Helm Charts

ArgoCD natively supports Helm:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  source:
    repoURL: https://github.com/your-org/helm-charts
    targetRevision: main
    path: charts/my-app
    helm:
      valueFiles:
        - values-prod.yaml
```

## Cost Considerations

### Development Environment

| Component | Configuration | Monthly Cost (us-east-1) |
|-----------|--------------|-------------------------|
| Server (1 replica) | 100m CPU, 128Mi RAM | ~$3 |
| Repo Server (1 replica) | 100m CPU, 256Mi RAM | ~$4 |
| Controller (1 replica) | 250m CPU, 512Mi RAM | ~$10 |
| Redis | 50m CPU, 64Mi RAM | ~$2 |
| **Total** | | **~$19/month** |

### Production Environment (HA)

| Component | Configuration | Monthly Cost (us-east-1) |
|-----------|--------------|-------------------------|
| Server (3 replicas) | 500m CPU, 512Mi RAM each | ~$45 |
| Repo Server (3 replicas) | 500m CPU, 1Gi RAM each | ~$90 |
| Controller (3 replicas) | 1000m CPU, 2Gi RAM each | ~$180 |
| Redis HA (3 replicas) | 100m CPU, 128Mi RAM each | ~$9 |
| **Total** | | **~$324/month** |

*Does not include ingress/ALB costs (~$16/month per ALB)*

## Troubleshooting

### Application Stuck in "Unknown" Status

**Symptom**: Application health shows as Unknown

```bash
# Check application details
argocd app get <app-name>

# Check sync status
argocd app sync <app-name> --dry-run

# Check ArgoCD controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

### Repository Connection Failed

**Symptom**: "connection failed" error when adding repository

```bash
# Test Git access from ArgoCD namespace
kubectl run -it --rm debug --image=alpine/git --restart=Never -n argocd -- \
  git ls-remote https://github.com/your-org/repo.git

# Check credentials secret
kubectl get secret -n argocd git-repository-credentials -o yaml

# Re-add repository
argocd repo add https://github.com/your-org/repo.git \
  --username user \
  --password token
```

### Sync Failing with Permission Errors

**Symptom**: Sync fails with RBAC errors

```bash
# Check ArgoCD service account permissions
kubectl auth can-i create deployments \
  --as=system:serviceaccount:argocd:argocd-application-controller \
  -n target-namespace

# If missing, add RBAC:
kubectl create rolebinding argocd-admin \
  --clusterrole=admin \
  --serviceaccount=argocd:argocd-application-controller \
  -n target-namespace
```

### High Memory Usage on Repo Server

**Symptom**: Repo server OOMKilled

**Solution**: Increase resources:
```hcl
values = yamlencode({
  repoServer = {
    resources = {
      requests = { cpu = "500m", memory = "2Gi" }
      limits   = { cpu = "1000m", memory = "4Gi" }
    }
  }
})
```

## Security Best Practices

1. **Git Credentials**: Store tokens in AWS Secrets Manager:
   ```hcl
   data "aws_secretsmanager_secret_version" "git_token" {
     secret_id = "prod/argocd/git-token"
   }

   git_repository_password = data.aws_secretsmanager_secret_version.git_token.secret_string
   ```

2. **RBAC Configuration**: Limit user permissions:
   ```yaml
   configs:
     rbac:
       policy.csv: |
         p, role:developers, applications, get, */*, allow
         p, role:developers, applications, sync, */*, allow
         g, engineering-team, role:developers
   ```

3. **Network Policies**: Restrict ArgoCD network access
4. **TLS**: Always use TLS for production ingress
5. **SSO**: Enable SSO for enterprise authentication

## References

- [ArgoCD Official Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
- [GitOps Principles](https://www.gitops.tech/)
