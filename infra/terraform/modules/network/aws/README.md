# Hera - AWS Network Module

This module provisions the **full VPC networking layer** for an AWS environment in Hera.  
It is designed to support Kubernetes (EKS), internal services, VPC endpoints, NAT gateways, VPN gateways, and flow logs.


---

# What This Module Creates

## 1. VPC
Creates a dedicated Virtual Private Cloud with DNS hostname + DNS support options.

**Function:** Network boundary for all AWS resources.  
**Cost:** Free.

---

## 2. Internet Gateway (IGW)
Allows public subnets to reach the internet.

**Function:** Required for NAT gateways and public workloads.  
**Cost:** Free.

---

## 3. Public Subnets
Subnets with automatic assignment of public IP addresses.

**Function:** Required for NAT gateways, ALB, or public-facing components.  
**Cost:** Free.

---

## 4. Private Subnets
Isolated subnets for internal workloads (EKS worker nodes, internal services).

**Function:** Secure segmentation.  
**Cost:** Free.

---

## 5. NAT Gateway(s)
Created based on configuration:
- Single NAT gateway (cost-efficient)
- One NAT per AZ (high availability)

**Function:** Allows private subnets to access the internet securely.  
**Cost:**  
- NAT GW: **~$32/month** each  
- Data processing: **$0.045/GB**

**Recommended:**
- Dev/early-stage: **single NAT**
- Production: **one NAT per AZ**

---

## 6. Route Tables
- Public route table → IGW  
- Private route table(s) → NAT gateway(s)

**Function:** Controls traffic routing for each subnet.  
**Cost:** Free.

---

## 7. VPC Endpoints (Interface + Gateway)
Supports endpoints for:
- S3 (Gateway)
- ECR API / ECR DKR
- EC2 / EC2 Messages
- STS
- CloudWatch Logs

**Function:** Enables private subnets to reach AWS APIs without NAT.  
**Cost:**  
- Gateway: Free  
- Interface: **~$0.01-$0.02/hour** + data transfer

**Recommended:**
- Dev: Only essential endpoints (s3, ecr_api, ecr_dkr)  
- Prod: Full set for resilience and NAT cost reduction

---

## 8. Security Group for VPC Endpoints
Single SG shared by interface endpoints.

**Cost:** Free.

---

## 9. CloudWatch Flow Logs (Optional)
Logs VPC traffic to CloudWatch.

**Function:** Observability, debugging, security.  
**Cost:**  
- Log ingestion: **$0.50/GB**
- Log storage retention-based

**Recommended:**
- Dev: Off (enable only when debugging)  
- Prod: On (7-30 days retention)

---

## 10. VPN Gateway (Optional)
Used for connecting on-prem networks.

**Cost:**  
- **~$36/month** + data transfer  

**Recommended:**
- Dev: Off  
- Prod: On (only if required)

---

# Configurable Variables

Core configurable inputs:
- `vpc_cidr`
- `public_subnet_cidrs`
- `private_subnet_cidrs`
- `availability_zones`
- `enable_nat_gateway`
- `single_nat_gateway`
- `enable_vpc_endpoints`
- `vpc_endpoints` (subset or all supported)
- `enable_vpn_gateway`
- `enable_flow_logs`

---

# Recommendations

## Dev / Cost-Conscious Environments
| Feature | Recommendation |
|--------|---------------|
| NAT gateways | **Single NAT** |
| Flow logs | Off |
| VPC Endpoints | Minimal (s3, ecr_api, ecr_dkr) |
| VPN | Off |
| Multi-AZ | Optional |

## Production Environments
| Feature | Recommendation |
|--------|---------------|
| NAT gateways | **One per AZ** |
| Flow logs | On (7-30 days) |
| VPC Endpoints | Full suite |
| VPN | On if needed |
| Multi-AZ | Required |

---

# Estimated Total Monthly Cost (Dev)

| Component | Cost |
|-----------|------|
| 1 NAT | ~$32 |
| 3-4 Interface VPCE | ~$21-$30 |
| S3/ECR endpoint gateway | Free |
| Flow logs | Off |

**≈ $55/month**

---

# Estimated Total Monthly Cost (Production)

| Component | Cost |
|-----------|------|
| NAT per AZ (2) | ~$64 |
| Interface VPCE (6-8) | ~$40-$60 |
| Flow logs | ~$5-$20 |
| VPN | ~$36 |

**≈ $140-$180/month**

---

# Important Notes

- This module is intended to be **safe to destroy/recreate**.  
- Only the **bootstrap** module must remain persistent.  
- This module supports EKS and all AWS managed services out of the box with proper tagging.

