# AWS Network Module

Provisions AWS VPC infrastructure including subnets, route tables, NAT gateways, and Internet gateways.

## Resources Created

- VPC with DNS support enabled
- Public subnets (one per AZ) with auto-assign public IP
- Private subnets (one per AZ)
- Internet Gateway for public subnet access
- NAT Gateways (one per AZ) for private subnet egress
- Route tables and associations
- VPC endpoints (optional, for S3, ECR, etc.)

## AWS-Specific Considerations

- **Multi-AZ**: Distribute subnets across multiple availability zones for high availability
- **NAT Gateway HA**: Consider creating NAT gateway per AZ vs. single NAT for cost optimization
- **VPC Endpoints**: Recommended for S3, ECR, and other AWS services to reduce data transfer costs
- **Flow Logs**: Enable VPC flow logs for network traffic analysis and security
- **CIDR Planning**: Ensure CIDR blocks don't overlap with existing VPCs if using VPC peering

## Cost Optimization

- NAT Gateways are expensive ($0.045/hour + data processing)
- For dev environments, consider single NAT gateway or NAT instances
- VPC endpoints can reduce data transfer costs significantly
