# ==============================================================================
# Local Values
# ==============================================================================
# This module manages AWS-level identity only.
# Kubernetes RBAC mappings are handled per-cluster in cluster-auth-mapping.
# ==============================================================================

locals {
  user_keys = keys(var.users)

  group_members = {
    for group_key, group in var.groups : group_key => [
      for member in group.members : member
      if contains(local.user_keys, member)
    ]
  }

  permission_set_assignments = flatten([
    for group_key, group in var.groups : [
      for ps_name in group.permission_sets : {
        key              = "${group_key}-${ps_name}"
        group_key        = group_key
        permission_set   = ps_name
      }
    ]
  ])

  permission_set_assignments_map = {
    for assignment in local.permission_set_assignments :
    assignment.key => assignment
  }
}
