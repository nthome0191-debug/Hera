# ==============================================================================
# IAM User Management Outputs
# ==============================================================================

output "iam_users" {
  description = "Map of created IAM users"
  value       = module.iam_users.iam_users
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

# ==============================================================================
# Kubernetes RBAC Outputs (when configured)
# ==============================================================================

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created (null if K8s not configured)"
  value       = length(module.kubernetes_rbac) > 0 ? module.kubernetes_rbac[0].kubernetes_rbac_groups : null
}

output "cluster_roles" {
  description = "Created ClusterRole names (null if K8s not configured)"
  value       = length(module.kubernetes_rbac) > 0 ? module.kubernetes_rbac[0].cluster_roles : null
}

# ==============================================================================
# Cluster Auth Mapping Outputs (when configured)
# ==============================================================================

output "user_mappings" {
  description = "IAM user to Kubernetes group mappings (null if K8s not configured)"
  value       = length(module.eks_auth_mapping) > 0 ? module.eks_auth_mapping[0].user_mappings : null
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access (null if K8s not configured)"
  value       = length(module.eks_auth_mapping) > 0 ? module.eks_auth_mapping[0].kubeconfig_instructions : null
}