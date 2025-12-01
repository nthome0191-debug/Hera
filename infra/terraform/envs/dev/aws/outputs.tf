# Development Environment Outputs - AWS

# TODO: Define outputs from the modules
#
# output "vpc_id" {
#   description = "VPC ID"
#   value       = module.network.vpc_id
# }
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

output "state_bucket" {
  value = module.bootstrap.bucket_name
}

output "state_lock_table" {
  value = module.bootstrap.lock_table_name
}

output "admin_role_arn" {
  value = module.bootstrap.admin_role_arn
}
