# ==============================================================================
# SSO Permission Sets - The "Hera" Zero-Trust Implementation
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. InfraManager: Full Access + Safety Guardrails
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "infra_manager" {
  name             = "InfraManager"
  description      = "Infrastructure manager - Full infra access with K8s admin"
  instance_arn     = local.sso_instance_arn
  session_duration = local.session_duration
  tags             = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "infra_manager" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_manager.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InfraManagementAccess"
        Effect = "Allow"
        Action = [
          "ec2:*", "eks:*", "elasticloadbalancing:*", "autoscaling:*",
          "cloudwatch:*", "logs:*", "kms:*", "secretsmanager:*",
          "s3:*", "dynamodb:*", "route53:*", "acm:*", "ecr:*", "ssm:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDestructiveCriticalOps"
        Effect = "Deny"
        Action = [
          "s3:DeleteBucket", "dynamodb:DeleteTable", "kms:ScheduleKeyDeletion",
          "cloudtrail:DeleteTrail", "config:DeleteConfigurationRecorder"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyIAMCredentialManagement" # Enforces SSO-only
        Effect = "Deny"
        Action = [
          "iam:CreateUser", "iam:CreateAccessKey", "iam:CreateLoginProfile"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 2. InfraMember: Power User (No Deletion of Core Infra)
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "infra_member" {
  name             = "InfraMember"
  description      = "Infrastructure member - Modify existing resources"
  instance_arn     = local.sso_instance_arn
  session_duration = local.session_duration
  tags             = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "infra_member" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.infra_member.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyEverything"
        Effect = "Allow"
        Action = ["ec2:Describe*", "eks:Describe*", "eks:List*", "s3:Get*", "s3:List*"]
        Resource = "*"
      },
      {
        Sid    = "ModifyResources"
        Effect = "Allow"
        Action = [
          "ec2:ModifyInstanceAttribute", "eks:UpdateNodegroupConfig",
          "autoscaling:UpdateAutoScalingGroup", "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 3. Developer: EKS Auth Only
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "developer" {
  name             = "Developer"
  description      = "Developer - EKS authentication only"
  instance_arn     = local.sso_instance_arn
  session_duration = local.session_duration
  tags             = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "developer" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSAuthentication"
        Effect = "Allow"
        Action = ["eks:DescribeCluster", "eks:ListClusters", "sts:GetCallerIdentity"]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 4. SecurityEngineer: Read-Only Audit Access
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "security_engineer" {
  name             = "SecurityEngineer"
  description      = "Security engineer - Read-only auditing"
  instance_arn     = local.sso_instance_arn
  session_duration = local.session_duration
  tags             = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "security_engineer" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_engineer.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecurityAuditAccess"
        Effect = "Allow"
        Action = [
          "cloudtrail:LookupEvents", "guardduty:Get*", "securityhub:Get*",
          "iam:Get*", "iam:List*", "access-analyzer:Get*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# Lookup Map for Account Assignments
# ------------------------------------------------------------------------------
locals {
  permission_set_arns = {
    "InfraManager"     = aws_ssoadmin_permission_set.infra_manager.arn
    "InfraMember"      = aws_ssoadmin_permission_set.infra_member.arn
    "Developer"        = aws_ssoadmin_permission_set.developer.arn
    "SecurityEngineer" = aws_ssoadmin_permission_set.security_engineer.arn
  }
}