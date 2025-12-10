locals {
  # Map Hera roles to Kubernetes RBAC groups
  role_to_k8s_groups = {
    "infra-manager" = [
      "hera:infra-managers",
      "system:masters", # Cluster admin access
    ]
    "infra-member" = [
      "hera:infra-members",
    ]
    "developer" = [
      "hera:developers",
    ]
    "security-engineer" = [
      "hera:security-engineers",
    ]
  }

  # Map IAM users to K8s groups based on their roles
  user_mappings = flatten([
    for user_key, user in var.users : [
      for role in user.roles : {
        userarn  = aws_iam_user.users[user_key].arn
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
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "access-management"
    }
  )
}
