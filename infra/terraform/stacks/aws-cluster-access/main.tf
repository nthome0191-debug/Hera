locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# Kubernetes RBAC (Cloud-Agnostic)
# ==============================================================================
# Creates ClusterRoles and ClusterRoleBindings with environment-aware permissions.
# Permissions differ by environment:
# - dev: Developers & Security Engineers get full CRUD
# - staging/prod: Developers & Security Engineers get read-only
# ==============================================================================

module "kubernetes_rbac" {
  source = "../../modules/kubernetes-rbac"

  environment = var.environment
  project     = var.project
  tags        = local.tags
}

module "eks_auth_mapping" {
  source = "../../modules/cluster-auth-mapping/aws-eks"

  cluster_name  = var.cluster_name
  environment   = var.environment
  region        = var.region
  project       = var.project
  sso_role_arns = var.sso_role_arns

  depends_on = [module.kubernetes_rbac]
}