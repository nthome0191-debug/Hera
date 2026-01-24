
resource "aws_eks_access_entry" "sso" {
  for_each = { for k, v in var.sso_role_arns : k => v if v != null }

  cluster_name      = var.cluster_name
  principal_arn     = each.value
  kubernetes_groups = local.permission_set_to_k8s_groups[each.key]
  type              = "STANDARD"
}
