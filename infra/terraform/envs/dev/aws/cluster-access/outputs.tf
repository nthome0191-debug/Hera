# ==============================================================================
# Cluster Access Outputs
# ==============================================================================

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created"
  value       = module.aws_cluster_access.kubernetes_rbac_groups
}

output "cluster_roles" {
  description = "Created ClusterRole names"
  value       = module.aws_cluster_access.cluster_roles
}

output "user_mappings" {
  description = "IAM user to Kubernetes group mappings"
  value       = module.aws_cluster_access.user_mappings
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access"
  value       = module.aws_cluster_access.kubeconfig_instructions
}
