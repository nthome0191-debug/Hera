module "platform" {
  source = "../../../../stacks/platform"

  project            = var.project
  environment        = var.environment
  tags               = var.tags
  kubeconfig_path    = var.kubeconfig_path
  kubeconfig_context = var.kubeconfig_context

  # ArgoCD
  argocd_chart_version  = var.argocd_chart_version
  argocd_admin_password = var.argocd_admin_password
  argocd_values         = var.argocd_values
}
