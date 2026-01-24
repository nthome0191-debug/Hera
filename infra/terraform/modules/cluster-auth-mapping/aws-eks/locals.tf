# ==============================================================================
# Local Values
# ==============================================================================
# K8s RBAC group mapping is defined here (environment-specific concern).
# Identity Center only provides SSO role ARNs - no K8s knowledge there.
# ==============================================================================

locals {
  # Permission set name to Kubernetes groups mapping
  # This defines what K8s groups each SSO role gets access to
  permission_set_to_k8s_groups = {
    "InfraManager"     = ["${var.project}:infra-managers", "system:masters"]
    "InfraMember"      = ["${var.project}:infra-members"]
    "Developer"        = ["${var.project}:developers"]
    "SecurityEngineer" = ["${var.project}:security-engineers"]
  }

  # Build SSO role entries for aws-auth ConfigMap
  # Maps SSO role ARNs to K8s groups based on permission set name
  sso_role_entries = [
    for ps_name, role_arn in var.sso_role_arns : {
      rolearn  = role_arn
      username = "sso:{{SessionName}}"
      groups   = lookup(local.permission_set_to_k8s_groups, ps_name, [])
    }
    if role_arn != null
  ]

  common_tags = merge(
    var.tags,
    {
      Project   = var.project
      ManagedBy = "Terraform"
      Module    = "cluster-auth-mapping-aws-eks"
    }
  )
}
