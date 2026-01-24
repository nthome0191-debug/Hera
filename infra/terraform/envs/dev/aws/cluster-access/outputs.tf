# ==============================================================================
# Cluster Access Outputs (SSO)
# ==============================================================================

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created"
  value       = module.aws_cluster_access.kubernetes_rbac_groups
}

output "cluster_roles" {
  description = "Created ClusterRole names"
  value       = module.aws_cluster_access.cluster_roles
}

output "sso_role_mappings" {
  description = "SSO role to Kubernetes group mappings"
  value       = module.aws_cluster_access.sso_role_mappings
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access via SSO"
  value       = module.aws_cluster_access.kubeconfig_instructions
}
