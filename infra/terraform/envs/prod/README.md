# Production Environment

Production environment configurations for long-lived, highly-available Kubernetes clusters.

## Characteristics

- **Lifecycle**: Long-lived, rarely destroyed
- **Cost**: Optimized for reliability over cost
- **HA**: Multi-AZ deployment required
- **Instances**: Production-grade instance types, no Spot/Preemptible
- **Networking**: NAT gateway per AZ for high availability
- **Autoscaling**: Conservative scale-down policies
- **Monitoring**: Enhanced monitoring and alerting
- **Backups**: Regular backups and disaster recovery

## Cloud Implementations

- **aws/**: AWS EKS production cluster
- **azure/**: Azure AKS production cluster
- **gcp/**: GCP GKE production cluster

## Example Configuration Values

### Networking
- VPC CIDR: 10.1.0.0/16
- Public Subnets: 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24
- Private Subnets: 10.1.10.0/24, 10.1.11.0/24, 10.1.12.0/24
- NAT Gateway per AZ: true
- Multi-AZ: 3 availability zones

### Kubernetes
- Version: Stable release (N-1)
- Node Groups:
  - System: 3 nodes minimum, m5.large (AWS) / Standard_D4s_v3 (Azure) / e2-standard-4 (GCP)
  - Workload: 3-20 nodes, autoscaling, on-demand instances only
- Private Endpoint: true
- Public Endpoint: true (restricted IPs)
- Encryption at rest: enabled
- Enhanced logging: enabled

## Security Requirements

1. Private cluster endpoint mandatory
2. Public endpoint with strict IP restrictions
3. Encryption at rest for all data
4. Regular security patching
5. Network policies enforced
6. Pod security standards enforced
7. Audit logging enabled
8. Secrets encrypted with KMS/Key Vault

## Disaster Recovery

1. Automated backups of cluster state
2. Infrastructure as Code stored in version control
3. Regular disaster recovery drills
4. Multi-region failover capability (future)
5. RTO/RPO defined and tested

## Change Management

1. All changes via pull requests
2. Terraform plan review required
3. Apply during maintenance windows
4. Rollback plan for all changes
5. Change notifications to team
