# Hera Project Structure

This document provides an overview of the complete project structure.

## Directory Tree

```
hera/
├── README.md                          # Main project README
├── ARCHITECTURE.md                    # Architecture documentation
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # MIT License
├── Makefile                          # Build automation
├── go.mod                            # Go module definition
├── .gitignore                        # Git ignore rules
├── .editorconfig                     # Editor configuration
│
├── infra/                            # Infrastructure as Code
│   └── terraform/
│       ├── modules/                  # Reusable Terraform modules
│       │   ├── network/              # Network modules (VPC, subnets, etc.)
│       │   │   ├── README.md         # Network module interface documentation
│       │   │   ├── aws/              # AWS VPC implementation
│       │   │   │   ├── README.md
│       │   │   │   ├── main.tf
│       │   │   │   ├── variables.tf
│       │   │   │   └── outputs.tf
│       │   │   ├── azure/            # Azure VNet implementation
│       │   │   │   ├── README.md
│       │   │   │   ├── main.tf
│       │   │   │   ├── variables.tf
│       │   │   │   └── outputs.tf
│       │   │   └── gcp/              # GCP VPC implementation
│       │   │       ├── README.md
│       │   │       ├── main.tf
│       │   │       ├── variables.tf
│       │   │       └── outputs.tf
│       │   │
│       │   ├── kubernetes-cluster/   # Kubernetes cluster modules
│       │   │   ├── README.md         # Cluster module interface documentation
│       │   │   ├── aws-eks/          # AWS EKS implementation
│       │   │   │   ├── README.md
│       │   │   │   ├── main.tf
│       │   │   │   ├── variables.tf
│       │   │   │   └── outputs.tf
│       │   │   ├── azure-aks/        # Azure AKS implementation
│       │   │   │   ├── README.md
│       │   │   │   ├── main.tf
│       │   │   │   ├── variables.tf
│       │   │   │   └── outputs.tf
│       │   │   └── gcp-gke/          # GCP GKE implementation
│       │   │       ├── README.md
│       │   │       ├── main.tf
│       │   │       ├── variables.tf
│       │   │       └── outputs.tf
│       │   │
│       │   └── platform/             # Platform components
│       │       ├── README.md
│       │       └── base/             # Base platform module
│       │           ├── README.md
│       │           ├── main.tf
│       │           ├── variables.tf
│       │           ├── outputs.tf
│       │           └── providers.tf
│       │
│       └── envs/                     # Environment compositions
│           ├── README.md
│           ├── dev/                  # Development environment
│           │   ├── README.md
│           │   ├── aws/
│           │   │   ├── main.tf
│           │   │   ├── variables.tf
│           │   │   ├── outputs.tf
│           │   │   ├── providers.tf
│           │   │   ├── backend.tf
│           │   │   └── terraform.tfvars.example
│           │   ├── azure/
│           │   │   ├── main.tf
│           │   │   ├── variables.tf
│           │   │   └── outputs.tf
│           │   └── gcp/
│           │       ├── main.tf
│           │       ├── variables.tf
│           │       └── outputs.tf
│           └── prod/                 # Production environment
│               ├── README.md
│               ├── aws/
│               │   ├── main.tf
│               │   ├── variables.tf
│               │   └── outputs.tf
│               ├── azure/
│               │   └── main.tf
│               └── gcp/
│                   └── main.tf
│
├── k8s/                              # Kubernetes manifests
│   ├── README.md
│   ├── base/                         # Base manifests (environment-agnostic)
│   │   ├── README.md
│   │   ├── kustomization.yaml
│   │   └── namespaces.yaml
│   └── overlays/                     # Environment-specific overlays
│       ├── dev/
│       │   ├── README.md
│       │   └── kustomization.yaml
│       └── prod/
│           ├── README.md
│           └── kustomization.yaml
│
├── operators/                        # Kubernetes operators
│   ├── README.md
│   ├── redis-operator/               # Redis operator
│   │   ├── README.md
│   │   └── main.go
│   ├── mongo-operator/               # MongoDB operator
│   │   ├── README.md
│   │   └── main.go
│   └── secrets-operator/             # Secrets synchronization operator
│       ├── README.md
│       └── main.go
│
├── pkg/                              # Shared Go packages/libraries
│   ├── README.md
│   └── platform/                     # Core platform abstractions
│       ├── README.md
│       ├── types.go
│       └── interfaces.go
│
└── cmd/                              # Command-line tools
    ├── README.md
    └── infractl/                   # Cluster management CLI
        ├── README.md
        ├── main.go
        └── cmd/
            └── root.go
```

## Component Summary

### Infrastructure (Terraform)

**Modules**: Reusable, cloud-specific implementations
- **network/**: VPC, subnets, NAT gateways, routing
  - AWS VPC, Azure VNet, GCP VPC
  - Consistent interface across clouds
- **kubernetes-cluster/**: Managed Kubernetes services
  - AWS EKS, Azure AKS, GCP GKE
  - Node groups, RBAC, add-ons
- **platform/base/**: Essential platform components
  - Metrics server, autoscaler, policies

**Environments**: Composition-only configurations
- **dev/**: Development clusters (cost-optimized, ephemeral)
- **prod/**: Production clusters (HA, resilient)
- Each environment supports AWS, Azure, GCP

### Kubernetes Manifests

**Kustomize-based structure**:
- **base/**: Environment-agnostic base resources
- **overlays/**: Environment-specific customizations
  - Dev overlay: Debug-friendly, permissive
  - Prod overlay: Strict, production-grade

### Operators

Custom Kubernetes operators for managing:
- **redis-operator**: Redis instances and clusters
- **mongo-operator**: MongoDB replica sets and sharded clusters
- **secrets-operator**: External secret synchronization

### Go Code

- **pkg/**: Shared libraries and platform abstractions
  - Cloud-agnostic interfaces
  - Reusable utilities
- **cmd/infractl/**: CLI for cluster management
  - Multi-cloud cluster operations
  - Unified command interface

## Quick Start Locations

### To deploy infrastructure:
```bash
cd infra/terraform/envs/dev/aws
# Copy and customize terraform.tfvars.example
terraform init
terraform apply
```

### To apply Kubernetes manifests:
```bash
kubectl apply -k k8s/overlays/dev
```

### To build the CLI:
```bash
make build-infractl
```

### To work on operators:
```bash
cd operators/redis-operator
# Follow operator README for development
```

## Documentation Locations

- **Main README**: `/README.md` - Project overview
- **Architecture**: `/ARCHITECTURE.md` - Architecture and design
- **Contributing**: `/CONTRIBUTING.md` - Contribution guidelines
- **Module READMEs**: Each module has detailed implementation docs
- **Operator READMEs**: Each operator has CRD and usage docs

## Next Steps

1. **Implement Terraform Modules**: Start with AWS network and EKS modules
2. **Implement Operators**: Begin with redis-operator
3. **Build CLI Tools**: Develop infractl commands
4. **Create Example Configurations**: Add working examples
5. **Set Up CI/CD**: GitHub Actions for testing and validation

All placeholders are marked with `TODO:` comments indicating what needs to be implemented.
