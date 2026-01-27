# ==============================================================================
# Account Assignments
# ==============================================================================
# Assigns SSO groups to permission sets for the AWS account.
# This creates the IAM roles that SSO users assume when logging in.
# ==============================================================================

resource "aws_ssoadmin_account_assignment" "assignments" {
  for_each = local.permission_set_assignments_map

  instance_arn       = local.sso_instance_arn
  permission_set_arn = local.permission_set_arns[each.value.permission_set]

  principal_id   = aws_identitystore_group.groups[each.value.group_key].group_id
  principal_type = "GROUP"

  target_id   = local.aws_account_id
  target_type = "AWS_ACCOUNT"

  depends_on = [
    aws_identitystore_group.groups,
    aws_ssoadmin_permission_set.infra_manager,
    aws_ssoadmin_permission_set.infra_member,
    aws_ssoadmin_permission_set.developer,
    aws_ssoadmin_permission_set.security_engineer,
  ]
}

# ==============================================================================
# Data source to get the SSO role ARNs after assignment
# ==============================================================================
# Note: AWS creates roles with pattern:
# arn:aws:iam::{account}:role/aws-reserved/sso.amazonaws.com/{region}/AWSReservedSSO_{PermissionSetName}_{random}
#
# We use a data source to retrieve the exact ARNs for use in EKS aws-auth ConfigMap.

data "aws_iam_roles" "sso_roles" {
  for_each = toset(["InfraManager", "InfraMember", "Developer", "SecurityEngineer"])

  name_regex  = "AWSReservedSSO_${each.key}_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  depends_on = [aws_ssoadmin_account_assignment.assignments]
}
