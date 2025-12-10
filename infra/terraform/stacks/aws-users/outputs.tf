# access management output
output "iam_users" {
  description = "Map of created IAM users"
  value       = module.access_management.iam_users
}

output "iam_groups" {
  description = "Map of IAM groups"
  value       = module.access_management.iam_groups
}

output "console_login_url" {
  description = "AWS Console login URL"
  value       = module.access_management.console_login_url
}

output "user_credentials_secrets" {
  description = "Secrets Manager secret names for user credentials"
  value       = module.access_management.user_credentials_secrets
}

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created"
  value       = module.access_management.kubernetes_rbac_groups
}