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
