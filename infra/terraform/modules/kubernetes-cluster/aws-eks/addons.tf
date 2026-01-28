locals {
  enabled_addons = {
    for addon_key, addon_config in {
      "vpc-cni"            = var.eks_addons.vpc_cni
      "kube-proxy"         = var.eks_addons.kube_proxy
      "coredns"            = var.eks_addons.coredns
      "aws-ebs-csi-driver" = var.eks_addons.aws_ebs_csi_driver
    } : addon_key => addon_config if addon_config.enabled
  }
}

resource "aws_eks_addon" "main" {
  for_each = local.enabled_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = each.value.resolve_conflicts
  resolve_conflicts_on_update = each.value.resolve_conflicts
  
  service_account_role_arn = each.value.service_account_role_arn != "" ? each.value.service_account_role_arn : (
    each.key == "aws-ebs-csi-driver" && var.enable_irsa ? aws_iam_role.ebs_csi[0].arn : null
  )

  tags = local.common_tags
}
