# ==============================================================================
# AWS IAM Identity Center (SSO) Configuration
# ==============================================================================
# This module configures AWS IAM Identity Center for zero-trust authentication.
# Users authenticate via SSO portal with MFA, receiving temporary credentials.
# No long-lived access keys or passwords are stored in Terraform state.
# ==============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Get the Identity Center instance (automatically created in standalone accounts)
data "aws_ssoadmin_instances" "main" {}

locals {
  identity_store_id   = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  sso_instance_arn    = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  aws_account_id      = data.aws_caller_identity.current.account_id
  region              = data.aws_region.current.name
  session_duration    = var.session_duration

  common_tags = merge(var.tags, {
    Module    = "identity-center"
    ManagedBy = "Terraform"
  })
}
