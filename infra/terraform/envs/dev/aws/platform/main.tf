
locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "gitea" {
  source = "../../../modules/platform/gitea"

  cluster_name     = var.cluster_name
  namespace        = "git"
  create_namespace = true
  admin_username   = "gitea-admin"
  admin_email      = "admin@dev.local"
  tags             = local.tags

  depends_on = [module.eks_cluster]
}

provider "gitea" {
  base_url = module.gitea.service_url
  username = module.gitea.admin_username
  password = module.gitea.admin_password

  insecure = true
}

module "gitops_repository" {
  source = "../../../modules/gitea/repository"

  name            = "gitops-repo"
  description     = "GitOps repository for ArgoCD"
  private         = true

  readme_content  = "# GitOps Repository\nManaged by Terraform"
}


module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name     = var.cluster_name
  namespace        = "argocd"
  create_namespace = true

  git_repository_url      = module.gitops_repository.clone_url
  git_repository_username = module.gitea.admin_username
  git_repository_password = module.gitea.admin_password

  values = yamlencode({
    server = {
      replicas = 1
      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "200m", memory = "256Mi" }
      }
    }
    repoServer = {
      replicas = 1
      resources = {
        requests = { cpu = "100m", memory = "256Mi" }
        limits   = { cpu = "200m", memory = "512Mi" }
      }
    }
    controller = {
      replicas = 1
      resources = {
        requests = { cpu = "250m", memory = "512Mi" }
        limits   = { cpu = "500m", memory = "1Gi" }
      }
    }
  })

  tags = local.tags

  depends_on = [
    module.gitops_repository,
    module.gitea
  ]
}
