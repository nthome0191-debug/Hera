# Network outputs
output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "nat_gateway_ips" {
  value = module.network.nat_gateway_ips
}

output "availability_zones" {
  value = module.network.availability_zones
}

# EKS outputs
output "cluster_id" {
  value = module.eks_cluster.cluster_id
}

output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "region" {
  value = var.region
}

output "cluster_arn" {
  value = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  value = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  value = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  value = module.eks_cluster.node_security_group_id
}

output "cluster_iam_role_arn" {
  value = module.eks_cluster.cluster_iam_role_arn
}

output "node_iam_role_arn" {
  value = module.eks_cluster.node_iam_role_arn
}

output "oidc_provider_arn" {
  value = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks_cluster.oidc_provider_url
}

output "node_group_ids" {
  value = module.eks_cluster.node_group_ids
}

output "node_group_status" {
  value = module.eks_cluster.node_group_status
}

output "kubeconfig" {
  value     = module.eks_cluster.kubeconfig
  sensitive = true
}

output "eks_addons" {
  value = module.eks_cluster.eks_addons
}

output "ebs_csi_driver_role_arn" {
  value = module.eks_cluster.ebs_csi_driver_role_arn
}

output "cluster_autoscaler_role_arn" {
  value = module.eks_cluster.cluster_autoscaler_role_arn
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file for kubectl/platform access"
  value       = module.eks_cluster.kubeconfig_path
}

output "kubeconfig_context" {
  description = "Kubeconfig context name for this cluster"
  value       = module.eks_cluster.kubeconfig_context
}

# access management output
output "iam_users" {
  description = "Map of created IAM users"
  value       = module.access_management.iam_users
}

output "iam_groups" {
  description = "Map of IAM groups"
  value       = module.access_management.iam_groups
}

output "console_login_url" {
  description = "AWS Console login URL"
  value       = module.access_management.console_login_url
}

output "user_credentials_secrets" {
  description = "Secrets Manager secret names for user credentials"
  value       = module.access_management.user_credentials_secrets
}

output "kubernetes_rbac_groups" {
  description = "Kubernetes RBAC groups created"
  value       = module.access_management.kubernetes_rbac_groups
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access"
  value       = module.access_management.kubeconfig_instructions
}

output "cloudtrail_name" {
  value       = module.cloudtrail.cloudtrail_name
  description = "CloudTrail trail name created by this stack, or null"
}

output "cloudtrail_bucket_name" {
  value       = module.cloudtrail.cloudtrail_bucket_name
  description = "CloudTrail audit bucket name created by this stack, or null"
}
