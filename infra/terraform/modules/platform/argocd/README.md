# ArgoCD Module

## Overview

This module deploys ArgoCD, a declarative GitOps continuous delivery tool for Kubernetes. ArgoCD continuously monitors Git repositories and synchronizes the desired state with your Kubernetes clusters.

## What is ArgoCD?

ArgoCD is a Kubernetes-native continuous deployment system that:

- Monitors Git repositories for changes
- Automatically syncs desired state from Git into Kubernetes
- Shows live application health and sync status
- Supports rollbacks to previous Git commits
- Supports multiple deployment strategies (rolling, blue/green, canary)

## GitOps Workflow

Developer → Git Push → Git Repository → ArgoCD → Kubernetes  
Git acts as the **single source of truth**, and ArgoCD keeps the cluster in sync.

## Features

- Git as source of truth
- Automated continuous sync
- Multi-cluster support
- Web UI + CLI
- RBAC + SSO support
- Health monitoring and rollback
- Webhook integration
- Supports Kustomize, Helm, plain YAML, Jsonnet

## Architecture

ArgoCD consists of:

- **Server** (API + UI)
- **Repo Server** (watches Git repositories)
- **Application Controller** (sync engine)
- **Redis** (cache)

ArgoCD works with ANY Git backend:

- GitHub
- GitLab
- Bitbucket
- Gitea
- Any self-hosted Git

## Usage

### Basic Deployment

module "argocd" {
  source      = "../../../modules/platform/argocd"
  cluster_name = "my-cluster"
  namespace    = "argocd"
  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

## Connecting ArgoCD to Git

ArgoCD works with any Git backend.

### Example: GitHub

module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://github.com/org/gitops-repo"
  git_repository_username = "github-user"
  git_repository_password = var.github_token
}

### Example: GitLab

module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://gitlab.com/org/gitops-repo"
  git_repository_username = "gitlab-user"
  git_repository_password = var.gitlab_token
}

### Example: Bitbucket

module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name = var.cluster_name
  namespace    = "argocd"

  git_repository_url      = "https://bitbucket.org/org/gitops-repo"
  git_repository_username = "bitbucket-user"
  git_repository_password = var.bitbucket_password
}

## Using ArgoCD with In-Cluster Gitea (Recommended for Dev)

When using Gitea deployed inside the cluster, Terraform can now completely automate GitOps setup through the **gitea-repository** module.  
No manual repository creation is needed.

### Step 1: Deploy Gitea

module "gitea" {
  source          = "../../../modules/platform/gitea"
  cluster_name     = var.cluster_name
  namespace        = "git"
  create_namespace = true
  admin_username   = var.gitea_admin_username
  admin_email      = var.gitea_admin_email
}

### Step 2: Automatically create GitOps repo in Gitea

module "gitops_repository" {
  source = "../../../modules/platform/gitea-repository"

  name           = "gitops-repo"
  description    = "GitOps root repository"
  private        = true
  readme_content = "# GitOps Repository\nManaged by Terraform"
}

### Step 3: Deploy ArgoCD connected to the auto-created repository

module "argocd" {
  source          = "../../../modules/platform/argocd"
  cluster_name     = var.cluster_name
  namespace        = "argocd"
  create_namespace = true

  git_repository_url      = module.gitops_repository.clone_url
  git_repository_username = module.gitea.admin_username
  git_repository_password = module.gitea.admin_password

  tags = local.tags

  depends_on = [
    module.gitea,
    module.gitops_repository
  ]
}

Notes:
- No manual action in Gitea is required.
- Gitea is accessible from ArgoCD using Kubernetes DNS:
  http://gitea-http.git.svc.cluster.local:3000

## Production HA Configuration

(unchanged from your original README)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Kubernetes cluster name | string | n/a | yes |
| namespace | Kubernetes namespace for ArgoCD | string | "argocd" | no |
| create_namespace | Create namespace automatically | bool | false | no |
| chart_version | Helm chart version | string | "" | no |
| values | Helm values override (YAML) | string | "" | no |
| admin_password | Optional admin password (auto-generated if empty) | string | "" | no |
| git_repository_url | GitOps repo URL | string | "" | no |
| git_repository_username | Git username | string | "" | no |
| git_repository_password | Git password/token | string | "" | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace where ArgoCD is deployed |
| admin_password | ArgoCD admin password (sensitive) |
| server_service | Name of ArgoCD server service |
| kubectl_port_forward | Command for port-forwarding |

## Post-Deployment

### Access the UI

ARGOCD_PASSWORD=$(terraform output -raw argocd_admin_password)
kubectl port-forward -n argocd svc/argocd-server 8080:443
Open: https://localhost:8080  
Login: admin / $ARGOCD_PASSWORD

## CLI Usage

argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure

## Best Practices

- Store credentials in AWS Secrets Manager
- Use TLS (ingress)
- Use RBAC policies
- Use SSO for production
- Restrict network access with NetworkPolicies

## References

- https://argo-cd.readthedocs.io/
- https://github.com/argoproj/argo-cd
