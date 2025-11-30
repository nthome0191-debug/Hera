# GCP Network Module

Provisions GCP VPC infrastructure including subnets, Cloud Router, and Cloud NAT.

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
