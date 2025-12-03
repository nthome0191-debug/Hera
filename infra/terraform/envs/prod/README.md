# Production Environment

**Highly-available, production-grade Kubernetes infrastructure designed for 24/7 operation and business-critical workloads.**

## Philosophy

Production environments in Hera are designed for **reliability, security, and high availability**. These environments:
- Run 24/7 with multi-AZ redundancy
- Use production-grade instance types (mix of on-demand + spot for non-critical workloads)
- Implement comprehensive monitoring, logging, and alerting
- Follow strict change management processes
- Never destroyed without explicit business justification

## Implementation Status

```
envs/prod/
├── aws/      ✅ Production-ready (Multi-AZ VPC + EKS)
├── azure/    🔄 Planned (Multi-region VNet + AKS)
└── gcp/      🔄 Planned (Multi-region VPC + GKE)
```

## Characteristics Comparison

| Aspect | Development | Production |
|--------|-------------|------------|
| **Lifecycle** | Ephemeral (destroy nightly) | Persistent (24/7) |
| **HA** | Single-AZ acceptable | Multi-AZ required (3 AZs) |
| **Instances** | Spot/Preemptible | On-Demand (critical) + Spot (non-critical) |
| **Networking** | Single NAT gateway | NAT per AZ (HA) |
| **Node Groups** | 1-2 nodes | 3+ nodes per group |
| **Logging** | 1-day retention | 30-day retention |
| **Backups** | Optional | Required + tested |
| **Encryption** | Optional | Required (KMS) |
| **Change Process** | Direct apply | PR review + maintenance windows |

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

## Estimated Monthly Costs (AWS Production)

### Baseline Configuration (3 nodes, multi-AZ)

| Component | Cost |
|-----------|------|
| EKS control plane | $72 |
| 3× t3.large on-demand nodes | $150 |
| NAT gateways (2× multi-AZ) | $64 |
| VPC endpoints (full suite: 6-8) | $40-60 |
| CloudWatch logs (30-day retention) | $15-30 |
| EBS volumes (encrypted) | $10-20 |
| **Baseline Total** | **~$350-400/month** |

### Scaling Considerations

**Per additional worker node (t3.large on-demand):** ~$50/month
**Per additional worker node (t3.large spot):** ~$15-20/month (70% savings)

**Production cluster with 10 nodes (mix):**
- 3× on-demand system nodes: $150
- 7× spot application nodes: $105-140
- Other infrastructure: $250-300
- **Total: ~$500-600/month**

**Enterprise cluster with 20+ nodes:**
- 5× on-demand system nodes: $250
- 15× spot application nodes: $225-300
- Enhanced monitoring + backups: $50-100
- Other infrastructure: $300-350
- **Total: ~$825-1000/month**

---

## Deployment Process

### Initial Deployment

**Prerequisites:**
```bash
# 1. Bootstrap must exist
infractl apply aws bootstrap --auto-approve

# 2. Review and update terraform.tfvars
cd infra/terraform/envs/prod/aws
vim terraform.tfvars
```

**Deploy Production (Recommended: Maintenance Window)**

```bash
# 1. Plan and review ALL changes
infractl plan aws prod

# 2. Share plan with team for review
# (In real production: create PR, get approvals)

# 3. Apply during maintenance window
infractl apply aws prod --auto-approve

# 4. Verify cluster health
aws eks update-kubeconfig --region us-east-1 --name <prod-cluster-name>
kubectl get nodes
kubectl get pods -A
```

### Change Management

**Production changes must follow:**

1. **Pull Request Process**
   - Create feature branch
   - Update Terraform configurations
   - Run `terraform plan` and commit output
   - Request peer review
   - Require 2+ approvals

2. **Maintenance Windows**
   - Schedule changes during low-traffic periods
   - Notify stakeholders 24-48 hours in advance
   - Have rollback plan ready
   - Monitor during and after changes

3. **Rollback Procedure**
   ```bash
   # Revert to previous Terraform state
   git checkout <previous-commit>
   infractl plan aws prod
   infractl apply aws prod --auto-approve
   ```

4. **Change Validation**
   - Verify cluster health
   - Run smoke tests
   - Check application endpoints
   - Monitor for 1-2 hours post-change

---

## Production Readiness Checklist

Before going live with production:

### Infrastructure
- [ ] Multi-AZ deployment configured
- [ ] NAT gateway per AZ enabled
- [ ] VPC endpoints for all AWS services
- [ ] KMS encryption enabled for secrets
- [ ] Enhanced logging enabled (30-day retention)
- [ ] Backup strategy implemented

### Security
- [ ] Private cluster endpoint enabled
- [ ] Public endpoint restricted to office IPs
- [ ] IRSA enabled for all workloads needing AWS access
- [ ] Pod security standards enforced
- [ ] Network policies configured
- [ ] Security group rules audited

### Monitoring & Alerting
- [ ] CloudWatch alarms configured
- [ ] Metrics collection enabled
- [ ] Log aggregation configured
- [ ] On-call rotation defined
- [ ] Runbooks documented

### Disaster Recovery
- [ ] Backup schedule defined
- [ ] Recovery procedures documented
- [ ] DR drill completed successfully
- [ ] RTO/RPO defined and tested
- [ ] Multi-region failover plan (if required)

### Operations
- [ ] Change management process documented
- [ ] On-call runbooks created
- [ ] Team trained on infrastructure
- [ ] Monitoring dashboards created
- [ ] Incident response plan defined
