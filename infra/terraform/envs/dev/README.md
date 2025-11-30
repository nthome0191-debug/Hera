# Development Environment

Development environment configurations for ephemeral or short-lived Kubernetes clusters.

## Characteristics

- **Lifecycle**: Can be destroyed and recreated frequently (daily or after testing)
- **Cost**: Optimized for minimal cost
- **HA**: Single-AZ deployment acceptable
- **Instances**: Use smaller instance types, Spot/Preemptible where possible
- **Networking**: Single NAT gateway acceptable
- **Autoscaling**: More aggressive scale-down policies

## Cloud Implementations

- **aws/**: AWS EKS development cluster
- **azure/**: Azure AKS development cluster
- **gcp/**: GCP GKE development cluster

## Example Configuration Values

### Networking
- VPC CIDR: 10.0.0.0/16
- Public Subnets: 10.0.1.0/24, 10.0.2.0/24
- Private Subnets: 10.0.10.0/24, 10.0.11.0/24
- Single NAT Gateway: true

### Kubernetes
- Version: Latest stable
- Node Groups:
  - System: 2 nodes, t3.medium (AWS) / Standard_D2s_v3 (Azure) / e2-medium (GCP)
  - Workload: 1-5 nodes, autoscaling, Spot/Preemptible
- Private Endpoint: true
- Public Endpoint: true (restricted IPs)

## Quick Start

```bash
# AWS
cd aws
terraform init
terraform apply -var-file="terraform.tfvars"

# Destroy when done
terraform destroy
```

## Cost Saving Tips

1. Destroy environment when not in use
2. Use Spot/Preemptible instances
3. Use smaller instance types
4. Single NAT gateway instead of per-AZ
5. Disable unused add-ons
6. Use autoscaling with aggressive scale-down
