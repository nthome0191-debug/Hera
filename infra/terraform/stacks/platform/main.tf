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
  source = "../../modules/platform/argocd"

  namespace        = "argocd"
  create_namespace = true
  chart_version    = var.argocd_chart_version
  values           = var.argocd_values
  admin_password   = var.argocd_admin_password
  tags             = local.tags
}

########################################
# 2. Future Platform Services
########################################

# TODO: Add Istio service mesh
# module "istio" {
#   source = "../../modules/platform/istio"
#   ...
# }

# TODO: Add Kafka
# module "kafka" {
#   source = "../../modules/platform/kafka"
#   ...
# }
