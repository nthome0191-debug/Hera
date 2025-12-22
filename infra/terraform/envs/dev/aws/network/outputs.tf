# Pass through all network outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

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

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.network.nat_gateway_ids
}

output "nat_gateway_ips" {
  description = "List of NAT Gateway IPs"
  value       = module.network.nat_gateway_ips
}

# Helper outputs for cluster subnet mapping
output "dev_apps_private_subnet_ids" {
  description = "Private subnet IDs for dev-apps cluster"
  value       = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
}

output "dev_infra_private_subnet_ids" {
  description = "Private subnet IDs for dev-infra cluster"
  value       = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
}
