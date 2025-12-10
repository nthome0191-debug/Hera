# ==============================================================================
# Local Values
# ==============================================================================

locals {
  # Common tags
  common_tags = merge(
    var.tags,
    {
      Project   = var.project
      ManagedBy = "Terraform"
      Module    = "iam-user-management"
    }
  )

  # Map role names to groups for dynamic assignment
  role_to_group = {
    "infra-manager"     = aws_iam_group.infra_manager.name
    "infra-member"      = aws_iam_group.infra_member.name
    "developer"         = aws_iam_group.developer.name
    "security-engineer" = aws_iam_group.security_engineer.name
  }
}
