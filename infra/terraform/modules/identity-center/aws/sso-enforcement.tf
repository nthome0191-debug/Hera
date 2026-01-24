# ==============================================================================
# SSO Enforcement Policy
# ==============================================================================
# This policy prevents the creation of IAM user credentials, enforcing SSO-only
# authentication. It denies:
# - Creating IAM users with console passwords
# - Creating/updating access keys for IAM users
# - Creating login profiles (console access)
#
# This ensures all human access goes through AWS IAM Identity Center (SSO).
# There is NO option to disable this - SSO is the only authentication method.
# ==============================================================================

# Deny policy to prevent IAM user credential creation
resource "aws_ssoadmin_permissions_boundary_attachment" "enforce_sso" {
  for_each = local.permission_set_arns

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value

  permissions_boundary {
    customer_managed_policy_reference {
      name = aws_iam_policy.sso_enforcement.name
      path = "/"
    }
  }

  depends_on = [
    aws_ssoadmin_permission_set.infra_manager,
    aws_ssoadmin_permission_set.infra_member,
    aws_ssoadmin_permission_set.developer,
    aws_ssoadmin_permission_set.security_engineer,
    aws_iam_policy.sso_enforcement,
  ]
}

# IAM Policy that denies credential creation for IAM users
resource "aws_iam_policy" "sso_enforcement" {
  name        = "${var.project}-sso-enforcement"
  description = "Denies creation of IAM user credentials to enforce SSO-only authentication"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyIAMUserCredentialCreation"
        Effect = "Deny"
        Action = [
          # Deny creating users with passwords
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:DeleteLoginProfile",
          # Deny creating/managing access keys
          "iam:CreateAccessKey",
          "iam:UpdateAccessKey",
          "iam:DeleteAccessKey",
          # Deny creating IAM users entirely (users should be in Identity Center)
          "iam:CreateUser",
          "iam:DeleteUser",
          # Deny service-specific credentials
          "iam:CreateServiceSpecificCredential",
          "iam:UpdateServiceSpecificCredential",
          "iam:DeleteServiceSpecificCredential",
          "iam:ResetServiceSpecificCredential",
          # Deny SSH public keys for CodeCommit
          "iam:UploadSSHPublicKey",
          "iam:UpdateSSHPublicKey",
          "iam:DeleteSSHPublicKey",
        ]
        Resource = "*"
        Condition = {
          # Only apply to human users (not service accounts/roles)
          StringNotLike = {
            "aws:PrincipalArn" = [
              "arn:aws:iam::*:role/aws-service-role/*",
              "arn:aws:iam::*:role/${var.project}-*-service-*",
            ]
          }
        }
      },
      {
        Sid    = "DenyMFADeviceManagementForIAMUsers"
        Effect = "Deny"
        Action = [
          # MFA should be managed in Identity Center, not IAM
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:ResyncMFADevice",
        ]
        Resource = "arn:aws:iam::*:user/*"
      },
      {
        Sid    = "AllowReadOnlyIAMForAudit"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Purpose = "SSO Enforcement"
  })
}

# ==============================================================================
# Account-Level Password Policy (disable console password for IAM users)
# ==============================================================================

resource "aws_iam_account_password_policy" "disable_iam_passwords" {
  minimum_password_length        = 128
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = false
  max_password_age               = 1
  password_reuse_prevention      = 24
  hard_expiry                    = true
}
