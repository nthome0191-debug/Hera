# ==============================================================================
# Kubernetes RBAC Outputs
# ==============================================================================

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created"
  value       = module.kubernetes_rbac.kubernetes_rbac_groups
}

output "cluster_roles" {
  description = "Created ClusterRole names"
  value       = module.kubernetes_rbac.cluster_roles
}

# ==============================================================================
# Cluster Auth Mapping Outputs (SSO)
# ==============================================================================

output "sso_role_mappings" {
  description = "SSO role to Kubernetes group mappings"
  value       = module.eks_auth_mapping.sso_role_mappings
}

output "authentication_mode" {
  description = "Authentication mode (always SSO)"
  value       = module.eks_auth_mapping.authentication_mode
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access via SSO"
  value       = module.eks_auth_mapping.kubeconfig_instructions
}
