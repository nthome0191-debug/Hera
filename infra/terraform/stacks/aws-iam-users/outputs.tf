# ==============================================================================
# IAM User Management Outputs
# ==============================================================================

output "iam_users" {
  description = "Map of created IAM users"
  value       = module.iam_users.iam_users
}

output "iam_user_arns" {
  description = "Map of IAM user ARNs"
  value       = module.iam_users.iam_user_arns
}

output "iam_groups" {
  description = "Map of IAM groups"
  value       = module.iam_users.iam_groups
}

output "console_login_url" {
  description = "AWS Console login URL"
  value       = module.iam_users.console_login_url
}

output "user_credentials_secrets" {
  description = "Secrets Manager secret names for user credentials"
  value       = module.iam_users.user_credentials_secrets
}
