# Development Environment

**Cost-optimized, ephemeral Kubernetes environments designed for daily teardown/recreation workflows.**

## Philosophy

Development environments in Hera are designed to be **disposable**. The recommended workflow is:
- **End of day:** `infractl destroy aws dev --auto-approve`
- **Next morning:** `infractl apply aws dev --auto-approve`
- **Cost savings:** ~50-60% reduction vs. 24/7 operation

## Characteristics

| Aspect | Development | Production |
|--------|-------------|------------|
| **Lifecycle** | Ephemeral (destroy nightly) | Persistent (24/7) |
| **Cost Priority** | Minimize spend | Balance cost vs. reliability |
| **HA** | Single-AZ acceptable | Multi-AZ required |
| **Instances** | Spot/Preemptible | Mix of On-Demand + Spot |
| **Networking** | Single NAT gateway | NAT per AZ |
| **Autoscaling** | Aggressive scale-down | Conservative scale-down |
| **Logging** | 1-day retention | 7-30 day retention |

## Implementation Status

```
envs/dev/
├── aws/      ✅ Production-ready (VPC + EKS with spot nodes)
├── azure/    🔄 Planned (VNet + AKS)
└── gcp/      🔄 Planned (VPC + GKE)
```

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

## Quick Start (AWS)

**Recommended: Use infractl**

```bash
# Prerequisites: Bootstrap must exist
infractl apply aws bootstrap --auto-approve

# Deploy dev environment
infractl plan aws dev
infractl apply aws dev --auto-approve

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name)
kubectl get nodes

# Destroy when done (saves ~$5-7/day)
infractl destroy aws dev --auto-approve
```

**Alternative: Direct Terraform**

```bash
cd aws
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
terraform destroy -var-file="terraform.tfvars"
```

---

## Estimated Monthly Costs (AWS Dev)

### Full Month (24/7 Operation)
| Component | Cost |
|-----------|------|
| EKS control plane | $72 |
| 2× t3.medium spot nodes | $30-40 |
| Single NAT gateway | $32 |
| VPC endpoints (4) | $21 |
| CloudWatch logs (1-day retention) | $1-5 |
| **Total** | **~$155-170/month** |

### Nightly Teardown (Weekdays 8am-6pm)
| Component | Cost |
|-----------|------|
| EKS control plane (10 hrs/day × 22 days) | $33 |
| Spot nodes (10 hrs/day × 22 days) | $13-18 |
| NAT (10 hrs/day × 22 days) | $14 |
| VPC endpoints (10 hrs/day × 22 days) | $10 |
| CloudWatch logs | $1-3 |
| **Total** | **~$70-77/month** |

**Savings: ~$80-100/month (52% reduction)**

---

## Cost Optimization Strategy

### Destroy Nightly (Recommended)

```bash
# End of work day
infractl destroy aws dev --auto-approve

# Next morning
infractl apply aws dev --auto-approve  # ~15-20 minutes
```

### Destroy Weekends

```bash
# Friday evening
infractl destroy aws dev --auto-approve

# Monday morning
infractl apply aws dev --auto-approve
```

### Additional Savings

1. **Use spot instances** - 50-70% cheaper than on-demand
2. **Minimize VPC endpoints** - only essential ones (s3, ecr_api, ecr_dkr)
3. **Single NAT gateway** - saves $32/month per additional NAT
4. **Low log retention** - 1 day instead of 7-30 days
5. **Smaller instance types** - t3.small vs t3.medium when possible
6. **Disable unused addons** - only enable what you need
