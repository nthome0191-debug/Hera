output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}
output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "private_subnets" {
  description = "Map of private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "public_subnets" {
  description = "Map of public subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "nat_gateway_ips" {
  description = "The public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "endpoint_security_group_id" {
  description = "The Security Group ID for VPC Endpoints"
  value       = aws_security_group.endpoints.id
}