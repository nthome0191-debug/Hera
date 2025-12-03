# Hera - Platform Modules

Platform modules contain standalone, reusable platform components that run on Kubernetes clusters. Each module is independent and can be composed at the environment level.

## Implementation Status

platform/
├── gitea/                 ✅ Production-ready (in-cluster Git server)
├── gitea-repository/      ✅ Production-ready (automated repo creation via Gitea API)
├── argocd/                ✅ Production-ready (GitOps continuous delivery)
├── monitoring/            🔄 Planned (Prometheus + Grafana + Loki)
├── ingress/               🔄 Planned (NGINX/ALB ingress controllers)
├── cert-manager/          🔄 Planned (TLS certificate management)
├── external-secrets/      🔄 Planned (External secrets integration)
├── service-mesh/          🔄 Planned (Istio/Linkerd)
└── security/              🔄 Planned (Falco, OPA, policy enforcement)

Legend:
- ✅ Fully implemented and production-ready
- 🔄 Planned for future implementation

## Module Details

------------------------------------------------------------
### Gitea (Production-Ready)
Purpose:
Lightweight, self-hosted Git service running entirely inside Kubernetes.

What It Is:
- Standalone Git server (similar to GitHub)
- Web UI + REST API
- Supports organizations, teams, and permissions
- Used as internal in-cluster Git backend
- Fully open-source
- Ideal for dev or isolated environments

Key Features:
- Web UI for managing repositories
- REST API for automation
- Webhooks, SSH/HTTPS access
- PostgreSQL storage
- Persistent volumes for durability

Use Cases:
- Developer Git backend for dev environments
- Git backend for GitOps/ArgoCD
- Private projects inside air-gapped environments

Namespace: git  
Documentation: gitea/README.md

------------------------------------------------------------
### Gitea Repository (NEW – Production-Ready)

Purpose:
Automates creation and management of Git repositories inside a Gitea instance.

What It Is:
- Terraform module that provisions repositories via the Gitea API
- Removes need for manual repo creation
- Enables fully automated GitOps bootstrapping

Key Features:
- Create private or public repositories
- Auto-init with README.md
- Custom README support
- Optional gitignore + license templates
- Enable/disable issues, wiki, PRs
- Configure merge methods: merge commit, rebase, squash
- Set topics/tags
- Archive/unarchive repos
- Fully idempotent

Common Use Cases:
- Auto-create a “gitops-repo” before installing ArgoCD
- Automate repo creation for tenants or microservices
- Daily rebuild of ephemeral dev clusters
- Automated onboarding of new projects

Dependencies:
Requires a configured Gitea provider:
- base_url (cluster-internal URL)
- admin username/password

Documentation: gitea-repository/README.md

------------------------------------------------------------
### ArgoCD (Production-Ready)

Purpose:
GitOps continuous deployment for Kubernetes.

What It Is:
- Declarative Git → Kubernetes synchronization
- Works with ANY Git backend: GitHub, GitLab, Bitbucket, Gitea
- Web UI, CLI, API
- Monitors and enforces desired state from Git

Key Features:
- Automated sync
- Multi-cluster support
- Application health monitoring
- RBAC, SSO
- Progressive delivery
- Rollbacks

Namespace: argocd  
Documentation: argocd/README.md

------------------------------------------------------------
### Monitoring (Planned)
Prometheus, Grafana, Loki, Alertmanager, Tempo.

### Ingress (Planned)
NGINX, AWS ALB, Azure AGIC, GCP Ingress.

------------------------------------------------------------

## Deployment Patterns

Platform modules are deployed after the Kubernetes cluster exists:

1. Bootstrap (S3 + DynamoDB state)
2. Network (VPC)
3. Kubernetes Cluster (EKS)
4. Platform Layer (THIS DIRECTORY)
   - Gitea → optional Git backend
   - Gitea Repository → auto-create GitOps repo
   - ArgoCD → GitOps engine
   - Monitoring, Ingress (future)
5. Applications (synced by ArgoCD)

------------------------------------------------------------

## Module Comparison

Aspect | Gitea | Gitea Repository | ArgoCD
------ | ------ | ---------------- | -------
Purpose | Git server | Git repo provisioning | GitOps CD
Depends On | None | Gitea API | Any Git backend
Namespace | git | N/A | argocd
Standalone | Yes | Yes | Yes
Dev Usage | Internal Git | Auto-create repos | GitOps sync
Prod Usage | Rare | Internal org repos | Standard

------------------------------------------------------------

## Quick Start (Dev)

terraform apply

# Gitea UI:
kubectl port-forward -n git svc/gitea-http 3000:3000
Open: http://localhost:3000

# Gitea admin:
username: gitea-admin
password: terraform output -raw gitea_admin_password

# Gitea repository is automatically created by the gitea-repository module

# ArgoCD UI:
kubectl port-forward -n argocd svc/argocd-server 8080:443
Open: https://localhost:8080

------------------------------------------------------------

## References

- gitea/README.md
- gitea-repository/README.md
- argocd/README.md
- Hera Architecture Guide (../../../README.md)
- Environment Composition (../../envs)

