# ==============================================================================
# AWS Identity Center Stack
# ==============================================================================
# This stack provisions AWS IAM Identity Center (SSO) for zero-trust
# authentication. It creates users, groups, and permission sets that
# replace traditional IAM users with passwords and access keys.
# ==============================================================================

module "identity_center" {
  source = "../../modules/identity-center/aws"

  project = var.project

  session_duration = var.session_duration

  users = var.users

  groups = var.groups

  custom_permission_policies = var.custom_permission_policies
  enable_permission_boundary = var.enable_permission_boundary
  permission_boundary_arn    = var.permission_boundary_arn

  tags = var.tags
}
