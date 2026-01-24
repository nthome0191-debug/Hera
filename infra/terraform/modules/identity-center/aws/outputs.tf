# ==============================================================================
# Identity Center Module Outputs
# ==============================================================================

# ==============================================================================
# SSO Instance Information
# ==============================================================================

output "sso_instance_arn" {
  description = "ARN of the SSO instance"
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "Identity Store ID"
  value       = local.identity_store_id
}

output "sso_start_url" {
  description = "SSO portal start URL for user login"
  value       = "https://${local.identity_store_id}.awsapps.com/start"
}

# ==============================================================================
# Permission Set Information
# ==============================================================================

output "permission_set_arns" {
  description = "Map of permission set names to their ARNs"
  value       = local.permission_set_arns
}

# ==============================================================================
# SSO Role ARNs (for EKS aws-auth ConfigMap)
# ==============================================================================

output "sso_role_arns" {
  description = "Map of permission set names to their assumed IAM role ARNs"
  value = {
    for ps_name, roles_data in data.aws_iam_roles.sso_roles :
    ps_name => length(roles_data.arns) > 0 ? tolist(roles_data.arns)[0] : null
  }
}

output "sso_role_arn_patterns" {
  description = "Construction of the SSO Role path to avoid race conditions"
  value = {
    for ps_name in ["InfraManager", "InfraMember", "Developer", "SecurityEngineer"] :
    ps_name => "arn:aws:iam::${local.aws_account_id}:role/aws-reserved/sso.amazonaws.com/${local.region}/AWSReservedSSO_${ps_name}_*"
  }
}

# ==============================================================================
# User Information
# ==============================================================================

output "users" {
  description = "Map of created SSO users"
  value = {
    for user_key, user in aws_identitystore_user.users :
    user_key => {
      user_id      = user.user_id
      display_name = user.display_name
      email        = user.emails[0].value
    }
  }
}

# ==============================================================================
# Group Information
# ==============================================================================

output "groups" {
  description = "Map of created SSO groups"
  value = {
    for group_key, group in aws_identitystore_group.groups :
    group_key => {
      group_id    = group.group_id
      description = group.description
    }
  }
}

# ==============================================================================
# SSO Enforcement
# ==============================================================================

output "sso_enforcement_policy_arn" {
  description = "ARN of the SSO enforcement policy (denies IAM user credentials)"
  value       = aws_iam_policy.sso_enforcement.arn
}

# ==============================================================================
# Onboarding Information
# ==============================================================================

output "onboarding_instructions" {
  description = "Instructions for new users to access AWS"
  value       = <<-EOT
================================================================================
AWS IAM Identity Center - User Onboarding Instructions
================================================================================

SSO Portal URL: https://${local.identity_store_id}.awsapps.com/start
AWS Region: ${local.region}
AWS Account: ${local.aws_account_id}

STEP 1: Accept Email Invitation
-------------------------------
1. Check your email for an AWS SSO invitation
2. Click the invitation link and create your password
3. Set up MFA with an authenticator app (required)

STEP 2: Configure AWS CLI
-------------------------
Run the following command to configure SSO:

    aws configure sso

When prompted:
  - SSO session name: ${var.project}
  - SSO start URL: https://${local.identity_store_id}.awsapps.com/start
  - SSO region: ${local.region}
  - SSO registration scopes: leave default (press Enter)

Select your AWS account and role when prompted.
Choose a profile name (e.g., ${var.project}-dev)

STEP 3: Daily Login
-------------------
Each day (or when session expires), login with:

    aws sso login --profile ${var.project}-dev

This opens a browser for authentication with MFA.

STEP 4: EKS Access (if applicable)
----------------------------------
After SSO login, configure kubectl:

    aws eks update-kubeconfig \
      --region ${local.region} \
      --name <cluster-name> \
      --profile ${var.project}-dev

Then use kubectl normally - it will use your SSO credentials.

STEP 5: Verify Access
---------------------
Test your AWS access:

    aws sts get-caller-identity --profile ${var.project}-dev

================================================================================
EOT
}
