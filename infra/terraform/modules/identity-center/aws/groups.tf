# ==============================================================================
# SSO Groups
# ==============================================================================
# Groups organize users and are assigned to permission sets.
# This provides role-based access control similar to IAM groups.
# ==============================================================================

resource "aws_identitystore_group" "groups" {
  for_each = var.groups

  identity_store_id = local.identity_store_id
  display_name      = each.key
  description       = each.value.description
}

# ==============================================================================
# Group Memberships
# ==============================================================================

locals {
  group_memberships = flatten([
    for group_key, group in var.groups : [
      for member in group.members : {
        key       = "${group_key}-${member}"
        group_key = group_key
        user_key  = member
      }
      if contains(keys(var.users), member)
    ]
  ])

  group_memberships_map = {
    for membership in local.group_memberships :
    membership.key => membership
  }
}

resource "aws_identitystore_group_membership" "memberships" {
  for_each = local.group_memberships_map

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.groups[each.value.group_key].group_id
  member_id         = aws_identitystore_user.users[each.value.user_key].user_id
}
