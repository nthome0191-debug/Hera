# ==============================================================================
# SSO Users
# ==============================================================================
# Users are created directly in AWS IAM Identity Center.
# Each user will receive an email invitation to set up their account and MFA.
# No passwords or access keys are stored in Terraform state.
# ==============================================================================

resource "aws_identitystore_user" "users" {
  for_each = var.users

  identity_store_id = local.identity_store_id

  user_name    = each.key
  display_name = coalesce(each.value.display_name, "${each.value.first_name} ${each.value.last_name}")

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value   = each.value.email
    primary = true
  }
}
