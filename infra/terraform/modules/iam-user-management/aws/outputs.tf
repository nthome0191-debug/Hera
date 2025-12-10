# ==============================================================================
# Secrets Manager - Store Passwords
# ==============================================================================

resource "aws_secretsmanager_secret" "user_passwords" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.console_access
  }

  name = "${var.project}/users/${each.key}/initial-password"

  tags = merge(
    local.common_tags,
    {
      User = each.key
    }
  )
}

resource "aws_secretsmanager_secret_version" "user_passwords" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.console_access
  }

  secret_id = aws_secretsmanager_secret.user_passwords[each.key].id
  secret_string = jsonencode({
    username         = each.key
    initial_password = aws_iam_user_login_profile.console[each.key].password
    console_url      = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
    reset_required   = true
  })
}

# ==============================================================================
# Secrets Manager - Store Access Keys
# ==============================================================================

resource "aws_secretsmanager_secret" "access_keys" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.programmatic_access
  }

  name = "${var.project}/users/${each.key}/access-key"

  tags = merge(
    local.common_tags,
    {
      User = each.key
    }
  )
}

resource "aws_secretsmanager_secret_version" "access_keys" {
  for_each = {
    for user_key, user in var.users :
    user_key => user if user.programmatic_access
  }

  secret_id = aws_secretsmanager_secret.access_keys[each.key].id
  secret_string = jsonencode({
    username          = each.key
    access_key_id     = aws_iam_access_key.programmatic[each.key].id
    secret_access_key = aws_iam_access_key.programmatic[each.key].secret
  })
}

# ==============================================================================
# Module Outputs
# ==============================================================================

output "iam_users" {
  description = "Map of created IAM users"
  value = {
    for user_key, user in aws_iam_user.users :
    user_key => {
      arn       = user.arn
      name      = user.name
      unique_id = user.unique_id
    }
  }
}

output "iam_user_arns" {
  description = "Map of IAM user ARNs (for eks-access-management module)"
  value = {
    for user_key, user in aws_iam_user.users :
    user_key => user.arn
  }
}

output "iam_groups" {
  description = "Map of IAM groups"
  value = {
    infra-manager     = aws_iam_group.infra_manager.name
    infra-member      = aws_iam_group.infra_member.name
    developer         = aws_iam_group.developer.name
    security-engineer = aws_iam_group.security_engineer.name
  }
}

output "console_login_url" {
  description = "AWS Console login URL"
  value       = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}

output "user_credentials_secrets" {
  description = "Secrets Manager secret names for user credentials"
  value = {
    passwords = {
      for user_key, user in var.users :
      user_key => try(aws_secretsmanager_secret.user_passwords[user_key].name, null)
      if user.console_access
    }
    access_keys = {
      for user_key, user in var.users :
      user_key => try(aws_secretsmanager_secret.access_keys[user_key].name, null)
      if user.programmatic_access
    }
  }
}
