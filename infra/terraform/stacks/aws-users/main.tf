locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "access_management" {
  source = "../../modules/access-management/aws"

  environment          = var.environment
  region               = var.region
  aws_account_id       = var.aws_account_id
  project              = var.project
  cluster_name         = var.cluster_name
  users                = var.users
  enforce_password_policy = var.enforce_password_policy
  enforce_mfa             = var.enforce_mfa
  allowed_ip_ranges       = var.allowed_ip_ranges
  tags                    = local.tags
}