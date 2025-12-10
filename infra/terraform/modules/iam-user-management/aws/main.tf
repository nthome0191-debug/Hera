# ==============================================================================
# IAM User Management Module - Main Configuration
# ==============================================================================
# This module manages IAM users, groups, and policies.
# ==============================================================================

# ==============================================================================
# Password Policy Enforcement
# ==============================================================================

resource "aws_iam_account_password_policy" "strict" {
  count = var.enforce_password_policy ? 1 : 0

  minimum_password_length        = 16
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
  hard_expiry                    = false
}
