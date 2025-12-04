locals {
  tags = merge(
    var.tags,
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

########################################
# 1. GITEA DEPLOYMENT (via Helm)
########################################

module "gitea" {
  source = "../../../modules/platform/gitea"

  namespace        = var.gitea_namespace
  create_namespace = true

  admin_username = var.gitea_admin_username
  admin_password = var.gitea_admin_password
  admin_email    = var.gitea_admin_email

  values = var.gitea_values
  tags   = local.tags
}

########################################
# 2. GITOPS REPOSITORY IN GITEA
########################################

module "gitops_repository" {
  source = "../../../modules/gitea/repository"

  name        = "gitops-repo"
  description = "GitOps repository for ArgoCD"
  private     = true

  readme_content = <<-EOT
    # GitOps Repository

    This repository is managed by Terraform and used by ArgoCD to reconcile cluster state.
  EOT

  providers = {
    gitea = gitea.this
  }

  # Ensure repo creation runs only after Gitea is installed
  _gitea_depends_on = [
    module.gitea
  ]
}

########################################
# 3. ARGOCD DEPLOYMENT
########################################

module "argocd" {
  source = "../../../modules/platform/argocd"

  namespace        = var.argocd_namespace
  create_namespace = true
  admin_password   = var.argocd_admin_password
  values           = var.argocd_values
  tags             = local.tags

  git_repository_url      = module.gitops_repository.clone_url
  git_repository_username = var.gitea_admin_username
  git_repository_password = var.gitea_admin_password

  _platform_depends_on = [
    module.gitea,
    module.gitops_repository
  ]
}
