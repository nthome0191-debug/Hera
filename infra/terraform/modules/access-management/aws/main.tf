# ==============================================================================
# Access Management Module - Main Configuration
# ==============================================================================
# This module manages IAM users, groups, policies, and Kubernetes RBAC
# for the Hera infrastructure project.
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

# ==============================================================================
# CloudTrail Verification
# ==============================================================================
# Verify CloudTrail is enabled for audit logging
# This is a safety check to ensure user actions are logged

resource "null_resource" "verify_cloudtrail" {
  count = var.verify_cloudtrail ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
if [ -z "${try(data.aws_cloudtrail_trail.main[0].id, "")}" ]; then
  echo "WARNING: CloudTrail not found. User actions will not be logged."
  echo "CloudTrail name should be: ${var.project}-${var.environment}-trail"
  echo "Consider setting verify_cloudtrail = false if CloudTrail has a different name."
fi
EOF
  }
}
