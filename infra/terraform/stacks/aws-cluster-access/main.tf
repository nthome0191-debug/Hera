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
# Same user list, but permissions differ by environment:
# - dev: Developers & Security Engineers get full CRUD
# - staging/prod: Developers & Security Engineers get read-only
# ==============================================================================

module "kubernetes_rbac" {
  source = "../../modules/kubernetes-rbac"

  environment = var.environment
  project     = var.project
  tags        = local.tags
}

# ==============================================================================
# Cluster Auth Mapping - AWS EKS (EKS-Specific)
# ==============================================================================
# Maps IAM users to Kubernetes groups in the aws-auth ConfigMap.
# Requires IAM user ARNs from the global IAM user management.
# ==============================================================================

module "eks_auth_mapping" {
  source = "../../modules/cluster-auth-mapping/aws-eks"

  cluster_name   = var.cluster_name
  node_role_name = var.node_role_name
  environment    = var.environment
  region         = var.region
  project        = var.project
  iam_user_arns  = var.iam_user_arns
  users          = var.users
  tags           = local.tags
}
