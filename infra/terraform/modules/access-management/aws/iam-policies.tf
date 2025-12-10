# ==============================================================================
# IAM Policy: Infra Manager
# ==============================================================================

data "aws_iam_policy_document" "infra_manager" {
  # Allow most infrastructure operations
  statement {
    sid    = "InfraManagementAccess"
    effect = "Allow"
    actions = [
      "ec2:*",
      "eks:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "logs:*",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "route53:*",
      "acm:*",
      "ecr:*",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:DescribeParameters",
    ]
    resources = ["*"]
  }

  # Read-only security access
  statement {
    sid    = "SecurityReadAccess"
    effect = "Allow"
    actions = [
      "cloudtrail:LookupEvents",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:DescribeTrails",
      "config:Describe*",
      "config:Get*",
      "config:List*",
      "guardduty:Get*",
      "guardduty:List*",
      "securityhub:Get*",
      "securityhub:List*",
      "access-analyzer:List*",
      "access-analyzer:Get*",
    ]
    resources = ["*"]
  }

  # Deny destructive operations on critical resources
  statement {
    sid    = "DenyDestructiveCriticalOps"
    effect = "Deny"
    actions = [
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "dynamodb:DeleteTable",
      "kms:ScheduleKeyDeletion",
      "kms:DeleteAlias",
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "config:DeleteConfigurationRecorder",
      "config:StopConfigurationRecorder",
    ]
    resources = ["*"]
  }

  # Deny IAM user/role creation (admin only)
  statement {
    sid    = "DenyIAMUserManagement"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:CreateGroup",
      "iam:DeleteGroup",
      "iam:AttachUserPolicy",
      "iam:AttachRolePolicy",
      "iam:PutUserPolicy",
      "iam:PutRolePolicy",
    ]
    resources = ["*"]
  }

  # Require MFA for sensitive operations
  statement {
    sid    = "DenyNonMFADelete"
    effect = "Deny"
    actions = [
      "ec2:TerminateInstances",
      "eks:DeleteCluster",
      "eks:DeleteNodegroup",
      "rds:DeleteDBInstance",
    ]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "infra_manager" {
  name        = "${var.project}-${var.environment}-infra-manager"
  description = "Infrastructure manager policy for ${var.environment} environment"
  policy      = data.aws_iam_policy_document.infra_manager.json
  tags        = local.common_tags
}

# ==============================================================================
# IAM Policy: Infra Member
# ==============================================================================

data "aws_iam_policy_document" "infra_member" {
  # Allow read operations on all resources
  statement {
    sid    = "ReadOnlyAccess"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "eks:Describe*",
      "eks:List*",
      "elasticloadbalancing:Describe*",
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Describe*",
      "logs:Get*",
      "logs:FilterLogEvents",
      "s3:ListBucket",
      "s3:GetObject",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "ecr:Describe*",
      "ecr:List*",
      "ecr:BatchGet*",
    ]
    resources = ["*"]
  }

  # Allow modifications to existing resources (not creation/deletion)
  statement {
    sid    = "ModifyExistingResources"
    effect = "Allow"
    actions = [
      "ec2:ModifyInstanceAttribute",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:TagResource",
      "eks:UntagResource",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:SetDesiredCapacity",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:PutObject",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "infra_member" {
  name        = "${var.project}-${var.environment}-infra-member"
  description = "Infrastructure member policy for ${var.environment} environment"
  policy      = data.aws_iam_policy_document.infra_member.json
  tags        = local.common_tags
}

# ==============================================================================
# IAM Policy: Developer (Minimal AWS, K8s Only)
# ==============================================================================

data "aws_iam_policy_document" "developer" {
  # Only allow EKS cluster authentication
  statement {
    sid    = "EKSAuthentication"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }

  # Deny everything else
  statement {
    sid    = "DenyAllOtherAWS"
    effect = "Deny"
    actions = [
      "ec2:*",
      "s3:*",
      "dynamodb:*",
      "rds:*",
      "iam:*",
      "kms:*",
      "cloudtrail:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "developer" {
  name        = "${var.project}-${var.environment}-developer"
  description = "Developer policy for ${var.environment} environment - K8s access only"
  policy      = data.aws_iam_policy_document.developer.json
  tags        = local.common_tags
}

# ==============================================================================
# IAM Policy: Security Engineer
# ==============================================================================

data "aws_iam_policy_document" "security_engineer" {
  # Read-only access to security services
  statement {
    sid    = "SecurityServicesReadOnly"
    effect = "Allow"
    actions = [
      "cloudtrail:LookupEvents",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:GetInsightSelectors",
      "guardduty:Get*",
      "guardduty:List*",
      "guardduty:Describe*",
      "securityhub:Get*",
      "securityhub:List*",
      "securityhub:Describe*",
      "config:Describe*",
      "config:Get*",
      "config:List*",
      "config:SelectResourceConfig",
      "access-analyzer:Get*",
      "access-analyzer:List*",
      "inspector:Describe*",
      "inspector:Get*",
      "inspector:List*",
      "inspector2:Get*",
      "inspector2:List*",
    ]
    resources = ["*"]
  }

  # IAM read-only (for security analysis)
  statement {
    sid    = "IAMReadOnly"
    effect = "Allow"
    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:GenerateCredentialReport",
    ]
    resources = ["*"]
  }

  # VPC Flow Logs read access
  statement {
    sid    = "VPCFlowLogsRead"
    effect = "Allow"
    actions = [
      "ec2:DescribeFlowLogs",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = ["*"]
  }

  # S3 read for security logs
  statement {
    sid    = "S3SecurityLogsRead"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "arn:aws:s3:::*cloudtrail*",
      "arn:aws:s3:::*cloudtrail*/*",
      "arn:aws:s3:::*config*",
      "arn:aws:s3:::*config*/*",
    ]
  }
}

resource "aws_iam_policy" "security_engineer" {
  name        = "${var.project}-${var.environment}-security-engineer"
  description = "Security engineer policy for ${var.environment} environment - read-only security access"
  policy      = data.aws_iam_policy_document.security_engineer.json
  tags        = local.common_tags
}

# ==============================================================================
# MFA Enforcement Policy
# ==============================================================================

data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid    = "DenyAllExceptListedIfNoMFA"
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "sts:GetSessionToken",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
    ]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "require_mfa" {
  count = var.enforce_mfa ? 1 : 0

  name        = "${var.project}-${var.environment}-require-mfa"
  description = "Enforce MFA for all operations except MFA setup"
  policy      = data.aws_iam_policy_document.require_mfa.json
  tags        = local.common_tags
}

# ==============================================================================
# IP Restriction Policy (Optional)
# ==============================================================================

data "aws_iam_policy_document" "ip_restriction" {
  count = length(var.allowed_ip_ranges) > 0 ? 1 : 0

  statement {
    sid    = "DenyAccessOutsideAllowedIPs"
    effect = "Deny"
    actions = [
      "*"
    ]
    resources = ["*"]
    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = var.allowed_ip_ranges
    }
    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "ip_restriction" {
  count = length(var.allowed_ip_ranges) > 0 ? 1 : 0

  name        = "${var.project}-${var.environment}-ip-restriction"
  description = "Restrict access to allowed IP ranges"
  policy      = data.aws_iam_policy_document.ip_restriction[0].json
  tags        = local.common_tags
}
