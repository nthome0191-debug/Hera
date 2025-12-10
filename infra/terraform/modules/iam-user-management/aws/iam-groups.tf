# ==============================================================================
# IAM Groups
# ==============================================================================

resource "aws_iam_group" "infra_manager" {
  name = "${var.project}-infra-manager"
  path = "/${var.project}/"
}

resource "aws_iam_group" "infra_member" {
  name = "${var.project}-infra-member"
  path = "/${var.project}/"
}

resource "aws_iam_group" "developer" {
  name = "${var.project}-developer"
  path = "/${var.project}/"
}

resource "aws_iam_group" "security_engineer" {
  name = "${var.project}-security-engineer"
  path = "/${var.project}/"
}

# ==============================================================================
# Attach Policies to Groups
# ==============================================================================

resource "aws_iam_group_policy_attachment" "infra_manager" {
  group      = aws_iam_group.infra_manager.name
  policy_arn = aws_iam_policy.infra_manager.arn
}

resource "aws_iam_group_policy_attachment" "infra_member" {
  group      = aws_iam_group.infra_member.name
  policy_arn = aws_iam_policy.infra_member.arn
}

resource "aws_iam_group_policy_attachment" "developer" {
  group      = aws_iam_group.developer.name
  policy_arn = aws_iam_policy.developer.arn
}

resource "aws_iam_group_policy_attachment" "security_engineer" {
  group      = aws_iam_group.security_engineer.name
  policy_arn = aws_iam_policy.security_engineer.arn
}
