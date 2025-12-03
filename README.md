# Hera

**Production-ready Kubernetes infrastructure-as-code framework designed for cloud-agnostic, cost-efficient, and ephemeral-friendly deployments.**

Hera is a multi-cloud infrastructure mono-repo that provisions, manages, and orchestrates modern Kubernetes platforms. It provides a clean, modular Terraform architecture with built-in CLI tooling (`infractl`) for safe, dependency-aware infrastructure operations.

## Vision

Hera serves as a reusable infrastructure backbone for multi-project use, enabling fast and repeatable creation of ephemeral or long-lived Kubernetes clusters. It supports development, testing, and production environments while remaining entirely application-agnostic and cost-conscious.

**Key Philosophy:** Separate persistent bootstrap resources from ephemeral infrastructure to enable daily cluster recreation, reducing cloud costs by up to 60% for non-production environments.

## Key Features

### Core Infrastructure
- **Production-ready AWS EKS clusters** with managed node groups, IRSA, encryption, and addons
- **Modular VPC networking** with configurable NAT gateways, VPC endpoints, and flow logs
- **Bootstrap separation** - persistent S3/DynamoDB backend isolated from ephemeral infrastructure
- **CLI orchestration** (`infractl`) with dependency-aware apply/destroy and module targeting
- **Cost-optimized configurations** for dev (spot instances, single NAT) and prod (multi-AZ, on-demand)

### Architecture
- Cloud-agnostic module interfaces (AWS implemented, Azure/GCP ready)
- Clean separation between cloud-specific implementation and environment composition
- Environment-based composition pattern (`envs/dev`, `envs/prod`, `envs/bootstrap`)
- No business logic in environments - only module orchestration
- Full support for `terraform destroy` with dependency enforcement

### Developer Experience
- Declarative infrastructure with consistent patterns across clouds
- Safe operations via `infractl` with automatic state inspection
- Comprehensive READMEs with cost breakdowns and architecture explanations
- Designed for fast iteration and ephemeral cluster workflows

## Repository Structure

```
hera/
├── README.md                          # This file
├── Makefile                           # Build targets for infractl CLI
│
├── cmd/
│   └── infractl/                      # ✅ Infrastructure orchestration CLI
│       ├── cmd/                       # Cobra command implementations
│       └── README.md                  # CLI usage guide
│
├── infra/terraform/
│   ├── modules/                       # Reusable Terraform modules
│   │   ├── bootstrap/                 # ✅ Persistent backend resources
│   │   │   └── aws/                   # S3 + DynamoDB state backend
│   │   │
│   │   ├── network/                   # VPC/networking layer
│   │   │   ├── aws/                   # ✅ Full AWS VPC implementation
│   │   │   ├── azure/                 # 🔄 Stub (future)
│   │   │   └── gcp/                   # 🔄 Stub (future)
│   │   │
│   │   ├── kubernetes-cluster/        # Managed Kubernetes clusters
│   │   │   ├── aws-eks/               # ✅ Production EKS with addons
│   │   │   ├── azure-aks/             # 🔄 Stub (future)
│   │   │   └── gcp-gke/               # 🔄 Stub (future)
│   │   │
│   │   └── platform/                  # 🔄 Platform components (future)
│   │       └── base/                  # ArgoCD, monitoring, etc.
│   │
│   └── envs/                          # Environment compositions
│       ├── bootstrap/aws/             # ✅ Bootstrap environment
│       ├── dev/aws/                   # ✅ Development environment
│       └── prod/aws/                  # ✅ Production environment
│
├── k8s/                               # 🔄 Kubernetes manifests (future)
│   ├── base/                          # Base Kustomize configs
│   └── overlays/                      # Environment overlays
│
├── operators/                         # 🔄 Custom K8s operators (future)
│   ├── redis-operator/
│   ├── mongo-operator/
│   └── secrets-operator/
│
└── pkg/                               # 🔄 Shared Go packages (future)
    └── platform/

Legend:
  ✅ Fully implemented and production-ready
  🔄 Stub/planned for future implementation
```

## Principles

-   Cloud-specific logic must remain inside cloud-specific module
    directories.
-   Module interfaces (inputs/outputs) must stay consistent across
    clouds.
-   Environments contain only composition logic, never business logic.
-   The project must remain application-agnostic.
-   Terraform resources must support full teardown via
    `terraform destroy`.
-   Future features (ArgoCD, operators, platform services) must
    integrate cleanly.

## Getting Started

### Prerequisites

- **Terraform** ≥ 1.6.0
- **AWS CLI** ≥ 2.x (for AWS deployments)
- **Go** ≥ 1.21 (for building `infractl`)
- Valid cloud provider credentials

### Quick Start (AWS)

#### 1. Build the CLI

```bash
make build-infractl
# Binary created at ./bin/infractl

# Optional: Install globally
make install-infractl
```

#### 2. Configure Environment

```bash
# Set Hera root directory
export HERA_ROOT="$HOME/Projects/Hera"
export PATH="$HERA_ROOT/bin:$PATH"

# Configure AWS credentials
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"

# Or use AWS SSO
aws sso login
```

#### 3. Bootstrap (Required First Step)

```bash
# Create S3 backend + DynamoDB table for remote state
infractl plan aws bootstrap
infractl apply aws bootstrap --auto-approve
```

**Note:** Bootstrap creates persistent resources (~$1-2/month) that must remain intact.

#### 4. Deploy Development Environment

```bash
# Plan network + EKS cluster
infractl plan aws dev

# Apply full environment
infractl apply aws dev --auto-approve

# Or apply modules individually
infractl apply aws dev network --auto-approve
infractl apply aws dev eks --auto-approve
```

#### 5. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
kubectl get nodes
```

#### 6. Destroy When Done (Cost Savings)

```bash
# Destroy entire environment (network destroyed automatically after EKS)
infractl destroy aws dev --auto-approve

# Destroy specific module (respects dependencies)
infractl destroy aws dev eks --auto-approve
```

### Alternative: Direct Terraform Usage

```bash
cd infra/terraform/envs/dev/aws
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

**Recommendation:** Use `infractl` for dependency management and safety checks.

## Infrastructure Costs (AWS)

### Bootstrap (Persistent)
- **S3 bucket**: ~$0.50/month (minimal state storage)
- **DynamoDB table**: ~$1.30/month (on-demand pricing)
- **Total**: ~$2/month

### Development Environment (Ephemeral)
- **EKS control plane**: $72/month (prorated if destroyed nightly)
- **2× t3.medium spot nodes**: ~$30-40/month (50-70% cheaper than on-demand)
- **Single NAT gateway**: $32/month + data transfer
- **VPC endpoints**: ~$21/month (3-4 interface endpoints)
- **CloudWatch logs**: $1-5/month (1-day retention)
- **Total**: ~$155-170/month (full month) or ~$80-100/month (nightly teardown)

### Production Environment (24/7)
- **EKS control plane**: $72/month
- **3× t3.large on-demand nodes (multi-AZ)**: ~$150/month
- **NAT gateways (2× multi-AZ)**: $64/month + data transfer
- **VPC endpoints**: ~$40/month (full suite)
- **CloudWatch logs**: $5-20/month (7-30 day retention)
- **Total**: ~$330-350/month (baseline, scales with nodes)

**Cost Optimization Strategy:**
Destroy dev environments nightly, keep only bootstrap persistent. Reduce monthly AWS spend by 50-60%.

---

## Architecture Highlights

### Module Dependency Graph

```
bootstrap (persistent)
    ↓
network (VPC, subnets, NAT, endpoints)
    ↓
eks-cluster (control plane, node groups, addons)
    ↓
platform (ArgoCD, monitoring) [future]
```

**Enforced by `infractl`:**
- Cannot apply EKS without network
- Cannot destroy network while EKS exists
- Bootstrap must exist before any environment

### Security Design

- **IRSA (IAM Roles for Service Accounts)** - pods use dedicated IAM roles, not node IAM
- **Encrypted EBS volumes** - all node volumes encrypted at rest
- **Private subnets** - worker nodes deployed in private subnets with NAT egress
- **Security groups** - separate SGs for control plane, nodes, and VPC endpoints
- **VPC endpoints** - private connectivity to AWS services without NAT
- **IMDSv2 enforced** - instance metadata protection enabled

### High Availability (Production)

- **Multi-AZ EKS control plane** - AWS-managed HA across 3 AZs
- **Multi-AZ node groups** - nodes distributed across availability zones
- **Multiple NAT gateways** - one per AZ to eliminate single point of failure
- **EBS CSI driver** - persistent volumes with automatic replication
- **Cluster autoscaler ready** - IRSA role pre-configured

---

## Module Documentation

Comprehensive module documentation with architecture diagrams, cost breakdowns, and configuration examples:

- **[Bootstrap Module](infra/terraform/modules/bootstrap/README.md)** - S3 + DynamoDB backend
- **[Network Module (AWS)](infra/terraform/modules/network/aws/README.md)** - VPC, subnets, NAT, endpoints
- **[EKS Module](infra/terraform/modules/kubernetes-cluster/aws-eks/README.md)** - Managed Kubernetes cluster
- **[infractl CLI](cmd/infractl/README.md)** - Infrastructure orchestration tool
- **[Environment Composition](infra/terraform/envs/README.md)** - Dev/Prod patterns

---

## Roadmap

### Phase 1: Multi-Cloud Expansion
- Azure AKS implementation (network + cluster modules)
- GCP GKE implementation (network + cluster modules)
- Multi-cloud environment examples

### Phase 2: Platform Components
- ArgoCD deployment via platform module
- Prometheus + Grafana observability stack
- Cert-manager for TLS automation
- External DNS integration

### Phase 3: GitOps & CI/CD
- Argo Workflows for Kubernetes-native CI
- BuildKit for container builds
- GitOps repository structure

### Phase 4: Custom Operators
- Redis operator for managed Redis clusters
- MongoDB operator for stateful workloads
- Secrets operator for external secrets management

---

## Contributing

This is a mono-repo template designed for customization. Key principles when extending:

1. **Keep modules cloud-agnostic at the interface level**
2. **Never put business logic in environment compositions**
3. **All resources must support clean `terraform destroy`**
4. **Update `infractl` dependency maps when adding new modules**
5. **Maintain comprehensive READMEs with cost breakdowns**

---

## License

This project is provided as-is for infrastructure learning and implementation.

---

**Hera** - Your foundation for creating consistent, cost-efficient, and maintainable Kubernetes infrastructure across clouds.
