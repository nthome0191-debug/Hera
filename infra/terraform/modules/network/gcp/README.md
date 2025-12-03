# GCP Network Module

🔄 **STATUS: PLANNED - NOT YET IMPLEMENTED**

This module is a **stub/placeholder** for future GCP VPC implementation. The AWS network module (`../aws/`) is production-ready and serves as the reference implementation.

## Planned Features

This module will provision GCP VPC infrastructure including:

## Resources Created

- VPC Network (auto-mode disabled, custom mode)
- Subnets with private IP ranges
- Cloud Router for NAT
- Cloud NAT for private subnet egress
- Firewall rules
- Private Google Access configuration

## GCP-Specific Considerations

- **Global VPC**: GCP VPCs are global, subnets are regional
- **Custom Mode**: Use custom mode VPC for better control over IP ranges
- **Cloud Router**: Required for Cloud NAT
- **Cloud NAT**: Provides outbound connectivity without external IPs
- **Private Google Access**: Allows VMs without external IPs to access Google APIs
- **Firewall Rules**: VPC-level firewall rules instead of per-subnet
- **Secondary Ranges**: Consider secondary IP ranges for GKE pods and services

## Cost Optimization

- Cloud NAT pricing: per gateway + data processing
- Private Google Access is free and reduces egress costs
- Use preemptible VMs for cost savings in dev/test
