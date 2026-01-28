output "vpc_id" {
  description = "The ID of the VPC for the production environment"
  value       = module.network.vpc_id
}

output "cluster_details" {
  description = "Subnet mapping for all clusters in this environment"
  value       = module.network.cluster_network_layout
}

output "nat_gateway_public_ips" {
  value = module.network.nat_gateway_public_ips
}