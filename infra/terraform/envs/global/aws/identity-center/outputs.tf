# ==============================================================================
# Environment Outputs
# ==============================================================================

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
