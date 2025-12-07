# Terraform Stacks

This directory contains reusable **Terraform stacks** - pre-composed combinations of modules that represent common infrastructure patterns.

## Philosophy

The stacks architecture eliminates code duplication by separating:
- **Modules** (`/modules/`) - Atomic building blocks (network, EKS, ArgoCD, etc.)
- **Stacks** (`/stacks/`) - Composed, reusable infrastructure patterns
- **Environments** (`/envs/`) - Configuration-only, values per environment

## Available Stacks

### Cloud Cluster Stacks

| Stack | Description | Composition |
|-------|-------------|-------------|
| `aws-cluster` | AWS EKS cluster with networking | Network (VPC) + EKS |
| `azure-cluster` | Azure AKS cluster with networking | Network (VNet) + AKS |
| `gcp-cluster` | GCP GKE cluster with networking | Network (VPC) + GKE |
| `local-cluster` | Local KIND cluster for development | KIND cluster |

### Platform Stacks

| Stack | Description | Services |
|-------|-------------|----------|
| `platform` | Platform services on Kubernetes | ArgoCD, (future: Istio, Kafka, etc.) |

## Usage

### In Environment Configurations

Environments use stacks by simply calling them and passing configuration:

```hcl
# infra/terraform/envs/dev/aws-cluster/main.tf
module "aws_cluster" {
  source = "../../../stacks/aws-cluster"

  # Configuration values
  region      = "us-east-1"
  project     = "hera"
  environment = "dev"

  # Network config
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  # EKS config
  cluster_name       = "hera-dev-eks"
  kubernetes_version = "1.32"
  node_groups        = { ... }
}
```

### Adding New Stacks

1. Create a new directory: `stacks/<stack-name>/`
2. Add the following files:
   - `main.tf` - Module composition
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `versions.tf` - Terraform and provider requirements
3. **DO NOT** add `providers.tf` - provider configuration stays in environments

## Structure

```
stacks/
├── README.md                    # This file
├── aws-cluster/                 # AWS EKS + Network stack
│   ├── main.tf                  # Composes network + eks modules
│   ├── variables.tf             # All configuration variables
│   ├── outputs.tf               # Exposed outputs
│   └── versions.tf              # Provider requirements
├── azure-cluster/               # Azure AKS + Network stack
├── gcp-cluster/                 # GCP GKE + Network stack
├── local-cluster/               # KIND cluster stack
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
└── platform/                    # Platform services stack
    ├── main.tf                  # ArgoCD + future services
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

## Benefits

### 1. No Code Duplication
```
Before (duplicated):
├── envs/dev/aws/cluster/main.tf       (network + eks code)
├── envs/staging/aws/cluster/main.tf   (network + eks code - DUPLICATED)
└── envs/prod/aws/cluster/main.tf      (network + eks code - DUPLICATED)

After (reusable):
├── stacks/aws-cluster/main.tf         (network + eks code - ONCE)
├── envs/dev/aws-cluster/main.tf       (just calls stack)
├── envs/staging/aws-cluster/main.tf   (just calls stack)
└── envs/prod/aws-cluster/main.tf      (just calls stack)
```

### 2. Easy Multi-Cloud Support
Same pattern for AWS, Azure, GCP:
- `aws-cluster` → Network + EKS
- `azure-cluster` → Network + AKS
- `gcp-cluster` → Network + GKE

### 3. Platform as Code
The `platform` stack grows with your needs:
```hcl
# Today
module "argocd" { ... }

# Tomorrow
module "istio" { ... }
module "kafka" { ... }
module "prometheus" { ... }
```

### 4. Consistent Patterns
Every environment uses the same tested, proven infrastructure patterns.

## Future Enhancements

### Planned Stacks
- `azure-cluster` - AKS with networking
- `gcp-cluster` - GKE with networking
- `observability` - Prometheus, Grafana, Loki
- `service-mesh` - Istio/Linkerd
- `data-platform` - Kafka, Spark, Airflow

### Platform Stack Expansion
The platform stack will grow to include:
- Service mesh (Istio)
- Message broker (Kafka)
- Observability (Prometheus, Grafana)
- Secret management (External Secrets Operator)
- Certificate management (cert-manager)

## Best Practices

1. **Stacks are Compositions**: Don't add business logic, just compose modules
2. **No Provider Blocks**: Provider configuration belongs in environments
3. **Sensible Defaults**: Provide defaults for common configurations
4. **Complete Outputs**: Expose all important information from composed modules
5. **Documentation**: Add comments explaining the composition strategy
