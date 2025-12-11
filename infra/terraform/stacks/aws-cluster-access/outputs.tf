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
# Cluster Auth Mapping Outputs
# ==============================================================================

output "user_mappings" {
  description = "IAM user to Kubernetes group mappings"
  value       = module.eks_auth_mapping.user_mappings
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access"
  value       = module.eks_auth_mapping.kubeconfig_instructions
}
