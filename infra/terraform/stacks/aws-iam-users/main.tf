locals {
  tags = {
    Project     = var.project
    Environment = "global"
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# IAM User Management (Global, AWS-Specific)
# ==============================================================================
# This stack ONLY creates IAM users, groups, and policies.
# Kubernetes RBAC configuration is handled per-cluster in aws-cluster-access.
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
