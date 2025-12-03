# Azure Network Module

🔄 **STATUS: PLANNED - NOT YET IMPLEMENTED**

This module is a **stub/placeholder** for future Azure VNet implementation. The AWS network module (`../aws/`) is production-ready and serves as the reference implementation.

## Planned Features

This module will provision Azure VNet infrastructure including:

## Resources Created

- Virtual Network (VNet)
- Subnets (public and private)
- NAT Gateway for private subnet egress
- Public IP addresses for NAT Gateway
- Route tables and associations
- Network Security Groups (NSGs)

## Azure-Specific Considerations

- **Address Space**: Azure uses address spaces instead of CIDR at VNet level
- **Service Endpoints**: Use service endpoints for Azure SQL, Storage, etc.
- **NAT Gateway**: Azure NAT Gateway provides outbound connectivity for private subnets
- **NSGs**: Network Security Groups should be applied at subnet level
- **Azure Bastion**: Consider Azure Bastion for secure SSH/RDP access

## Cost Optimization

- NAT Gateway pricing: per hour + data processing
- Service endpoints are free and reduce egress costs
- Consider shared NAT Gateway across multiple subnets in dev environments
