# ==============================================================================
# Local Values
# ==============================================================================

locals {
  # Map project roles to Kubernetes RBAC groups
  role_to_k8s_groups = {
    "infra-manager" = [
      "${var.project}:infra-managers",
      "system:masters", # Cluster admin access
    ]
    "infra-member" = [
      "${var.project}:infra-members",
    ]
    "developer" = [
      "${var.project}:developers",
    ]
    "security-engineer" = [
      "${var.project}:security-engineers",
    ]
  }

  # Map IAM users to K8s groups based on their roles
  user_mappings = flatten([
    for user_key, user in var.users : [
      for role in user.roles : {
        userarn  = var.iam_user_arns[user_key]
        username = user_key
        groups   = local.role_to_k8s_groups[role]
      }
    ]
  ])

  # Deduplicate users (a user might have multiple roles)
  # Merge groups for the same user
  user_mappings_by_user = {
    for mapping in local.user_mappings :
    mapping.username => mapping...
  }

  user_mappings_final = [
    for username, mappings in local.user_mappings_by_user : {
      userarn  = mappings[0].userarn
      username = username
      groups   = distinct(flatten([for m in mappings : m.groups]))
    }
  ]

  # Common tags
  common_tags = merge(
    var.tags,
    {
      Project   = var.project
      ManagedBy = "Terraform"
      Module    = "cluster-auth-mapping-aws-eks"
    }
  )
}
