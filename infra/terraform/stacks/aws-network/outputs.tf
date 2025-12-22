# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

# Subnet Outputs
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.network.private_subnet_cidrs
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.network.public_subnet_cidrs
}

output "availability_zones" {
  description = "List of availability zones"
  value       = module.network.availability_zones
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.network.nat_gateway_ids
}

output "nat_gateway_ips" {
  description = "List of NAT Gateway IPs"
  value       = module.network.nat_gateway_ips
}

# Route Table Outputs
output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.network.private_route_table_ids
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.network.public_route_table_id
}

# VPC Endpoint Outputs
output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value       = module.network.vpc_endpoint_ids
}
