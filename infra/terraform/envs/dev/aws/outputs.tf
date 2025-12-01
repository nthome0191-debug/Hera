# Development Environment Outputs - AWS

# Network Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.network.nat_gateway_ips
}

output "availability_zones" {
  description = "Availability zones in use"
  value       = module.network.availability_zones
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = module.eks_cluster.node_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS nodes"
  value       = module.eks_cluster.node_iam_role_arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  value       = module.eks_cluster.oidc_provider_url
}

output "node_group_ids" {
  description = "Map of EKS node group IDs"
  value       = module.eks_cluster.node_group_ids
}

output "node_group_status" {
  description = "Map of EKS node group statuses"
  value       = module.eks_cluster.node_group_status
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = module.eks_cluster.kubeconfig
  sensitive   = true
}

output "eks_addons" {
  description = "Map of EKS addons and their versions"
  value       = module.eks_cluster.eks_addons
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = module.eks_cluster.ebs_csi_driver_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = module.eks_cluster.cluster_autoscaler_role_arn
}
