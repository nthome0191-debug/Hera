
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

output "cluster_network_layout" {
  description = "A mapping of each cluster name to its allocated subnets and AZs"
  value = {
    for c in var.clusters : c.name => {
      private_subnets = [for az in c.azs : module.network.private_subnets["${c.name}-${az}"]]
      public_subnets  = [for az in c.azs : module.network.public_subnets["${c.name}-${az}"]]
      azs             = c.azs
    }
  }
}

output "nat_gateway_public_ips" {
  description = "The public IPs of the NAT Gateways"
  value       = module.network.nat_gateway_ips
}

output "vpc_endpoint_sg_id" {
  description = "The Security Group ID for the ECR/EKS endpoints"
  value       = module.network.endpoint_security_group_id
}

# --- Future-Proofing for EKS ---
# Once you uncomment the EKS cluster module, you would add outputs like these:
/*
output "eks_cluster_endpoints" {
  description = "The API endpoints for the EKS clusters"
  value       = { for name, cluster in module.eks_clusters : name => cluster.endpoint }
}

output "eks_cluster_certificate_authority_data" {
  description = "The CA data for the clusters"
  value       = { for name, cluster in module.eks_clusters : name => cluster.certificate_authority_data }
}
*/