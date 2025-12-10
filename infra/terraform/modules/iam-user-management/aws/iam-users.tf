# ==============================================================================
# IAM Users
# ==============================================================================

resource "aws_iam_user" "users" {
  for_each = var.users

  name = each.key
  path = "/${var.project}/"

  tags = merge(
    local.common_tags,
    {
      Name  = each.value.full_name
      Email = each.value.email
    }
  )
}

# ==============================================================================
# Assign users to groups based on their roles
# ==============================================================================

resource "aws_iam_user_group_membership" "user_groups" {
  for_each = var.users

  user = aws_iam_user.users[each.key].name
  groups = [
    for role in each.value.roles :
    local.role_to_group[role]
  ]
}

# ==============================================================================
# Console Access (Login Profiles)
# ==============================================================================

resource "aws_iam_user_login_profile" "console" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.console_access
  }

  user                    = aws_iam_user.users[each.key].name
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_reset_required,
    ]
  }
}

# ==============================================================================
# Programmatic Access (Access Keys)
# ==============================================================================

resource "aws_iam_access_key" "programmatic" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.programmatic_access
  }

  user = aws_iam_user.users[each.key].name
}

# ==============================================================================
# MFA Enforcement (attach to users who require it)
# ==============================================================================

resource "aws_iam_user_policy_attachment" "mfa_enforcement" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.require_mfa && var.enforce_mfa
  }

  user       = aws_iam_user.users[each.key].name
  policy_arn = aws_iam_policy.require_mfa[0].arn
}

# ==============================================================================
# IP Restriction (attach to all users if enabled)
# ==============================================================================

resource "aws_iam_user_policy_attachment" "ip_restriction" {
  for_each = length(var.allowed_ip_ranges) > 0 ? var.users : {}

  user       = aws_iam_user.users[each.key].name
  policy_arn = aws_iam_policy.ip_restriction[0].arn
}
