output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "The name of the EKS cluster (with random suffix if enabled)"
  value       = local.name_prefix
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane"
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.node.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = aws_iam_role.cluster.name
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS nodes"
  value       = aws_iam_role.node.arn
}

output "node_iam_role_name" {
  description = "IAM role name of the EKS nodes"
  value       = aws_iam_role.node.name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS IRSA"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].arn : null
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider for EKS IRSA"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.cluster[0].url : null
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(aws_eks_cluster.main.identity[0].oidc[0].issuer, null)
}

output "node_group_ids" {
  description = "Map of node group IDs"
  value       = { for k, v in aws_eks_node_group.main : k => v.id }
}

output "node_group_arns" {
  description = "Map of node group ARNs"
  value       = { for k, v in aws_eks_node_group.main : k => v.arn }
}

output "node_group_status" {
  description = "Map of node group statuses"
  value       = { for k, v in aws_eks_node_group.main : k => v.status }
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for EKS control plane logs"
  value       = aws_cloudwatch_log_group.eks_cluster.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for EKS control plane logs"
  value       = aws_cloudwatch_log_group.eks_cluster.arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of IAM role for EBS CSI driver"
  value       = var.eks_addons.aws_ebs_csi_driver.enabled && var.enable_irsa ? aws_iam_role.ebs_csi[0].arn : null
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of IAM role for Cluster Autoscaler"
  value       = var.enable_cluster_autoscaler && var.enable_irsa ? aws_iam_role.cluster_autoscaler[0].arn : null
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster"
  value = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name           = local.name_prefix
    cluster_endpoint       = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = aws_eks_cluster.main.certificate_authority[0].data
    region                 = var.region
  })
  sensitive = true
}

output "eks_addons" {
  description = "Map of EKS addons and their versions"
  value       = { for k, v in aws_eks_addon.addons : k => v.addon_version }
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file (AWS EKS writes to default kubectl config)"
  value       = pathexpand("~/.kube/config")
}

output "kubeconfig_context" {
  description = "Kubeconfig context name to use for this cluster"
  value       = var.kubeconfig_context_name != "" ? var.kubeconfig_context_name : "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${local.name_prefix}"
}
