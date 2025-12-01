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

# EKS Cluster Outputs (to be uncommented when EKS module is implemented)
#
# output "cluster_id" {
#   description = "EKS cluster ID"
#   value       = module.eks_cluster.cluster_id
# }
#
# output "cluster_endpoint" {
#   description = "EKS cluster endpoint"
#   value       = module.eks_cluster.cluster_endpoint
# }
#
# output "kubeconfig" {
#   description = "Kubeconfig for cluster access"
#   value       = module.eks_cluster.kubeconfig
#   sensitive   = true
# }
#
# output "oidc_provider_arn" {
#   description = "OIDC provider ARN for IRSA"
#   value       = module.eks_cluster.oidc_provider_arn
# }
