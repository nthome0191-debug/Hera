# ==============================================================================
# Global AWS Identity Center Configuration
# ==============================================================================
# This environment provisions AWS IAM Identity Center for zero-trust
# authentication. Users defined here can access the AWS account via SSO
# with MFA, eliminating the need for long-lived access keys.
# ==============================================================================

module "identity_center" {
  source = "../../../stacks/aws-identity-center"
  project     = var.project
  environment = var.environment
  session_duration = var.session_duration
  users = var.users
  groups = var.groups

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Identity Center SSO"
    Layer = "Global"
  }
}
