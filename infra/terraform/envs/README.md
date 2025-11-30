# Environment Compositions

Environment directories contain composition-only Terraform configurations that orchestrate modules to create complete infrastructure stacks.

## Principles

1. **No Business Logic**: Environments contain only composition logic - module calls with variable passing
2. **Cloud-Specific**: Each environment has cloud-specific subdirectories (aws/, azure/, gcp/)
3. **DRY Configuration**: Use terraform.tfvars for environment-specific values
4. **State Management**: Each environment should have its own remote state
5. **Modular**: Environments should be independently deployable and destroyable

## Directory Structure

```
envs/
  dev/
    aws/
      main.tf          # Module composition
      variables.tf     # Variable declarations
      outputs.tf       # Output declarations
      terraform.tfvars # Environment-specific values
      providers.tf     # Provider configuration
      backend.tf       # Remote state configuration
    azure/
    gcp/
  staging/
    aws/
    azure/
    gcp/
  prod/
    aws/
    azure/
    gcp/
```

## Environment Lifecycle

### Dev Environment
- Short-lived, can be destroyed daily
- Smaller instance sizes
- Minimal HA requirements
- Cost optimization is priority
- Can use Spot/Preemptible instances
- Single NAT gateway acceptable

### Staging Environment
- Production-like configuration
- Used for integration testing
- Can be stopped/started but not destroyed frequently
- Balance between cost and HA

### Prod Environment
- Full HA configuration
- Multi-AZ deployment
- Production-grade instance sizes
- No Spot/Preemptible instances
- Multiple NAT gateways for HA
- Enhanced monitoring and logging

## Typical Environment Composition

An environment typically composes:
1. **Network Module**: Creates VPC/networking
2. **Kubernetes Cluster Module**: Creates K8s cluster
3. **Platform Base Module**: Installs platform components

The environment main.tf orchestrates these modules and passes outputs between them.

## Usage

```bash
cd envs/dev/aws
terraform init
terraform plan
terraform apply
```

## State Management

Each environment should configure remote state (S3, Azure Storage, GCS) to enable team collaboration and state locking.
