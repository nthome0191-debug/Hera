# ==============================================================================
# Stack Outputs
# ==============================================================================

output "sso_instance_arn" {
  description = "ARN of the SSO instance"
  value       = module.identity_center.sso_instance_arn
}

output "identity_store_id" {
  description = "Identity Store ID"
  value       = module.identity_center.identity_store_id
}

output "sso_start_url" {
  description = "SSO portal URL for user login"
  value       = module.identity_center.sso_start_url
}

output "sso_role_arns" {
  description = "Map of permission set names to their IAM role ARNs"
  value       = module.identity_center.sso_role_arns
}

output "users" {
  description = "Created SSO users"
  value       = module.identity_center.users
}

output "groups" {
  description = "Created SSO groups"
  value       = module.identity_center.groups
}

output "onboarding_instructions" {
  description = "User onboarding instructions"
  value       = module.identity_center.onboarding_instructions
}

output "sso_enforcement_policy_arn" {
  description = "ARN of the SSO enforcement policy (denies IAM user credentials)"
  value       = module.identity_center.sso_enforcement_policy_arn
}
