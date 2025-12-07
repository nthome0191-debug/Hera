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
# 1. ArgoCD Deployment
########################################

module "argocd" {
  source = "../../../modules/platform/argocd"

  namespace        = "argocd"
  create_namespace = true
  chart_version    = var.argocd_chart_version
  values           = var.argocd_values
  admin_password   = var.argocd_admin_password
  tags             = local.tags

  git_repository_url      = var.git_repository_url
  git_repository_username = var.git_repository_username
  git_repository_password = var.git_repository_password

  initial_app_name                = "guestbook"
  initial_app_path                = "guestbook" 
  initial_app_target_revision     = "HEAD"
  initial_app_destination_namespace = "guestbook-dev"
}
