# Cluster Outputs
output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster (with random suffix if enabled)"
  value       = module.eks_cluster.cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks_cluster.cluster_version
}

output "cluster_platform_version" {
  description = "The platform version for the cluster"
  value       = module.eks_cluster.cluster_platform_version
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data"
  value       = module.eks_cluster.cluster_ca_certificate
  sensitive   = true
}

# Security Group Outputs
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane"
  value       = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes (for cross-cluster communication)"
  value       = module.eks_cluster.node_security_group_id
}

# IAM Role Outputs
output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks_cluster.cluster_iam_role_name
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS nodes"
  value       = module.eks_cluster.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "IAM role name of the EKS nodes"
  value       = module.eks_cluster.node_iam_role_name
}

# IRSA Outputs
output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider for EKS IRSA"
  value       = module.eks_cluster.oidc_provider_url
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

# Node Group Outputs
output "node_group_ids" {
  description = "Map of node group IDs"
  value       = module.eks_cluster.node_group_ids
}

output "node_group_arns" {
  description = "Map of node group ARNs"
  value       = module.eks_cluster.node_group_arns
}

output "node_group_status" {
  description = "Map of node group statuses"
  value       = module.eks_cluster.node_group_status
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for EKS control plane logs"
  value       = module.eks_cluster.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for EKS control plane logs"
  value       = module.eks_cluster.cloudwatch_log_group_arn
}

# Service Account Role Outputs
output "ebs_csi_driver_role_arn" {
  description = "ARN of IAM role for EBS CSI driver"
  value       = module.eks_cluster.ebs_csi_driver_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of IAM role for Cluster Autoscaler"
  value       = module.eks_cluster.cluster_autoscaler_role_arn
}

# Kubeconfig Outputs
output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster"
  value       = module.eks_cluster.kubeconfig
  sensitive   = true
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = module.eks_cluster.kubeconfig_path
}

output "kubeconfig_context" {
  description = "Kubeconfig context name to use for this cluster"
  value       = module.eks_cluster.kubeconfig_context
}

# EKS Addons Output
output "eks_addons" {
  description = "Map of EKS addons and their versions"
  value       = module.eks_cluster.eks_addons
}
