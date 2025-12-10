locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Determine if K8s RBAC should be configured
  configure_k8s_rbac = var.cluster_name != "" && var.node_role_name != ""
}

# ==============================================================================
# IAM User Management (Global, AWS-Specific)
# ==============================================================================

module "iam_users" {
  source = "../../modules/iam-user-management/aws"

  project                 = var.project
  users                   = var.users
  enforce_password_policy = var.enforce_password_policy
  enforce_mfa             = var.enforce_mfa
  allowed_ip_ranges       = var.allowed_ip_ranges
  tags                    = local.tags
}

# ==============================================================================
# Kubernetes RBAC (Cloud-Agnostic, Optional)
# ==============================================================================

module "kubernetes_rbac" {
  count  = local.configure_k8s_rbac ? 1 : 0
  source = "../../modules/kubernetes-rbac"

  environment = var.environment
  project     = var.project
  tags        = local.tags
}

# ==============================================================================
# Cluster Auth Mapping - AWS EKS (EKS-Specific, Optional)
# ==============================================================================

module "eks_auth_mapping" {
  count  = local.configure_k8s_rbac ? 1 : 0
  source = "../../modules/cluster-auth-mapping/aws-eks"

  cluster_name   = var.cluster_name
  node_role_name = var.node_role_name
  environment    = var.environment
  region         = var.region
  project        = var.project
  iam_user_arns  = module.iam_users.iam_user_arns
  users          = var.users
  tags           = local.tags
}