# ==============================================================================
# Module Outputs
# ==============================================================================

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created"
  value = {
    infra-managers     = "hera:infra-managers"
    infra-members      = "hera:infra-members"
    developers         = "hera:developers"
    security-engineers = "hera:security-engineers"
  }
}

output "cluster_roles" {
  description = "Created ClusterRole names"
  value = {
    infra-member = kubernetes_cluster_role_v1.infra_member.metadata[0].name
    developer = var.environment == "dev" ? (
      length(kubernetes_cluster_role_v1.developer_full) > 0 ? kubernetes_cluster_role_v1.developer_full[0].metadata[0].name : null
      ) : (
      length(kubernetes_cluster_role_v1.developer_readonly) > 0 ? kubernetes_cluster_role_v1.developer_readonly[0].metadata[0].name : null
    )
    security-engineer = var.environment == "dev" ? (
      length(kubernetes_cluster_role_v1.security_engineer_full) > 0 ? kubernetes_cluster_role_v1.security_engineer_full[0].metadata[0].name : null
      ) : (
      length(kubernetes_cluster_role_v1.security_engineer_readonly) > 0 ? kubernetes_cluster_role_v1.security_engineer_readonly[0].metadata[0].name : null
    )
  }
}
