# Hera - Network Module (Multi-Cloud)

The Hera network module defines the **networking foundation** for running application workloads on AWS, Azure, or GCP.

It consists of provider-specific implementations:

```
modules/network/
├── aws/
├── azure/   (planned)
└── gcp/     (planned)
```

---

# Purpose of the Network Module

This module is responsible for creating the **full networking topology** required for application clusters, databases, and internal services.  
It supports Kubernetes clusters (EKS/AKS/GKE), VPC/VNet/VCN designs, service endpoints, NAT, routing, segmentation, and logging.

Because this layer is more expensive than bootstrap, it is designed to be **optionally ephemeral**:
- Bootstrap stays alive permanently
- Network + compute layers can be created/destroyed freely
- Dev/staging environments can be torn down nightly for major savings

---

# Why Separate Bootstrap and Network Layers?

### Bootstrap (Persistent)
- Terraform backend (S3/Blob/GCS)
- Locking table (Dynamo/Storage Table/Datastore)
- IAM backend
- Monthly cost: **$0.50-$3**

### Network (Optionally Ephemeral)
- VPC/VNet creation
- Subnets + routing + NAT
- Endpoints
- Observability (flow logs)
- VPN

Dev/staging environments can cost **$40-$180/month** depending on complexity.  
By isolating the network layer, we keep the expensive components optional and ephemeral.

---

# Provider-Specific Scope

## AWS Network Module
Implements:
- VPC
- Subnets
- NAT gateways
- IGW
- Route tables
- Interface/Gateway VPC endpoints
- Flow logs
- Optional VPN GW

Cost range:
- Dev: **≈ $55/month**
- Prod: **≈ $140-$180/month**

---

## Azure Network Module (Planned)
Will implement:
- VNet
- Subnets
- NAT Gateway/SNAT
- Route tables
- Private endpoints
- NSGs
- Flow logs

Cost estimate:
- Dev: `$40-$70`
- Prod: `$120-$180`

---

## GCP Network Module (Planned)
Will implement:
- VPC
- Subnets
- Cloud NAT
- Private Service Connect
- Firewall rules
- Flow logs

Cost estimate:
- Dev: `$35-$60`
- Prod: `$110-$160`

---

# Design Goals
- Cloud-agnostic
- Production-ready
- Cost-efficient for startups
- Fully compatible with EKS/AKS/GKE
- Easy to recreate/destroy
- Zero local state

---

# Recommended Strategy

### Dev / Early Stage
- Single NAT
- Few endpoints
- No VPN
- No flow logs
- Destroy nightly

### Production
- NAT per AZ
- Full endpoints
- VPN if required
- Flow logs enabled
- Multi-AZ always
