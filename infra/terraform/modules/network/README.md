# Network Modules

This directory contains cloud-specific network infrastructure modules. Each cloud provider has its own subdirectory with a consistent interface.

## Module Interface Contract

All network modules must expose the same input/output interface to maintain cloud-agnostic composition at the environment level.

### Required Inputs
- `environment` (string): Environment name (dev, staging, prod)
- `region` (string): Cloud region for deployment
- `vpc_cidr` (string): CIDR block for the VPC/VNet
- `availability_zones` (list): List of AZs/zones to use
- `private_subnet_cidrs` (list): CIDR blocks for private subnets
- `public_subnet_cidrs` (list): CIDR blocks for public subnets
- `enable_nat_gateway` (bool): Whether to create NAT gateway for private subnets
- `tags` (map): Common tags to apply to all resources

### Required Outputs
- `vpc_id`: The VPC/VNet identifier
- `private_subnet_ids`: List of private subnet IDs
- `public_subnet_ids`: List of public subnet IDs
- `nat_gateway_ips`: List of NAT gateway public IPs
- `route_table_ids`: Map of route table IDs

## Implementation Guidelines

1. **Cloud-Specific Logic**: Keep all cloud-specific resource definitions within the respective cloud directory
2. **Consistent Naming**: Use consistent resource naming patterns across clouds
3. **Security by Default**: Private subnets should not have direct internet access without NAT
4. **Tagging Strategy**: All resources must support tagging for cost allocation and management
5. **Documentation**: Each cloud module should have its own README with specific notes

## Cloud Implementations

- **aws/**: AWS VPC, subnets, route tables, NAT gateways, Internet gateways
- **azure/**: Azure VNet, subnets, route tables, NAT gateways
- **gcp/**: GCP VPC, subnets, Cloud NAT, Cloud Router
