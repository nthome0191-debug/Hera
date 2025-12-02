# infractl

A unified CLI for managing Hera Kubernetes clusters across AWS, Azure, and GCP.

## Overview

`infractl` is a command-line tool that provides a consistent interface for:
- Creating Kubernetes clusters
- Managing cluster lifecycle
- Querying cluster information
- Updating cluster configurations
- Managing platform components

## Features

- **Multi-Cloud Support**: Manage clusters across AWS EKS, Azure AKS, and GCP GKE
- **Unified Interface**: Same commands work across all cloud providers
- **Configuration Management**: Support for config files and environment variables
- **GitOps Ready**: Generate manifests for GitOps workflows
- **Interactive Mode**: Guided cluster creation
- **Template Support**: Reusable cluster templates

## Installation

```bash
# From source
go install github.com/yourorg/hera/cmd/infractl@latest

# Or build locally
cd cmd/infractl
go build -o infractl
sudo mv infractl /usr/local/bin/
```

## Usage

### Create a Cluster

```bash
# Interactive mode
infractl create cluster

# From config file
infractl create cluster --config cluster.yaml

# Quick create with defaults
infractl create cluster my-cluster --provider aws --region us-east-1
```

### Get Cluster Info

```bash
# List all clusters
infractl get clusters

# Get specific cluster
infractl get cluster my-cluster

# Get kubeconfig
infractl get kubeconfig my-cluster
```

### Update Cluster

```bash
# Update from config
infractl update cluster --config cluster.yaml

# Scale node group
infractl scale nodegroup my-cluster/workers --min 3 --max 10

# Upgrade version
infractl upgrade cluster my-cluster --version 1.29
```

### Delete Cluster

```bash
# Delete cluster
infractl delete cluster my-cluster

# Delete with confirmation skip
infractl delete cluster my-cluster --yes
```

## Configuration

### Config File Example

```yaml
apiVersion: hera.io/v1alpha1
kind: ClusterConfig
metadata:
  name: my-cluster
spec:
  provider: aws
  region: us-east-1
  version: "1.28"
  network:
    vpcCIDR: 10.0.0.0/16
    subnets:
      private:
        - 10.0.10.0/24
        - 10.0.11.0/24
      public:
        - 10.0.1.0/24
        - 10.0.2.0/24
  nodeGroups:
    - name: system
      instanceType: t3.medium
      minSize: 2
      maxSize: 3
    - name: workload
      instanceType: t3.large
      minSize: 1
      maxSize: 10
```

### Environment Variables

```bash
export HERA_PROVIDER=aws
export HERA_REGION=us-east-1
export AWS_PROFILE=my-profile
```

## Commands

### Global Flags

- `--config`: Path to config file
- `--provider`: Cloud provider (aws, azure, gcp)
- `--region`: Cloud region
- `--output`: Output format (json, yaml, table)
- `--verbose`: Enable verbose logging

### create

Create resources:
- `create cluster`: Create a new cluster
- `create nodegroup`: Add a node group to existing cluster

### get

Retrieve information:
- `get clusters`: List all clusters
- `get cluster`: Get cluster details
- `get kubeconfig`: Get kubeconfig for a cluster
- `get nodegroups`: List node groups

### update

Update resources:
- `update cluster`: Update cluster configuration
- `update nodegroup`: Update node group configuration

### delete

Delete resources:
- `delete cluster`: Delete a cluster
- `delete nodegroup`: Delete a node group

### scale

Scale resources:
- `scale nodegroup`: Scale a node group

### upgrade

Upgrade resources:
- `upgrade cluster`: Upgrade cluster Kubernetes version

### validate

Validate configurations:
- `validate config`: Validate a config file

## Implementation Plan

### Phase 1: Basic Commands
- [ ] CLI framework setup (Cobra)
- [ ] Config file parsing
- [ ] Basic create cluster command
- [ ] Basic get commands
- [ ] Basic delete cluster command

### Phase 2: Multi-Cloud Support
- [ ] AWS provider implementation
- [ ] Azure provider implementation
- [ ] GCP provider implementation
- [ ] Provider abstraction

### Phase 3: Advanced Features
- [ ] Update and scale commands
- [ ] Upgrade commands
- [ ] Template support
- [ ] Interactive mode

### Phase 4: GitOps & CI/CD
- [ ] Generate Terraform configs
- [ ] Generate Kubernetes manifests
- [ ] CI/CD integration helpers
- [ ] Drift detection

## Development

```bash
# Run locally
go run main.go create cluster --help

# Build
go build -o infractl

# Run tests
go test ./...

# Build for all platforms
make build-all
```

## Examples

See the `examples/` directory for example cluster configurations and use cases.
