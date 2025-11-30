# Platform Package

Core platform abstractions and interfaces for the Hera infrastructure platform.

## Overview

This package provides the foundational types and interfaces for managing Kubernetes clusters and platform components across cloud providers.

## Key Interfaces

### ClusterManager

Manages the lifecycle of Kubernetes clusters:

```go
type ClusterManager interface {
    // Create creates a new Kubernetes cluster
    Create(ctx context.Context, spec ClusterSpec) (*Cluster, error)

    // Get retrieves cluster information
    Get(ctx context.Context, name string) (*Cluster, error)

    // Update updates cluster configuration
    Update(ctx context.Context, spec ClusterSpec) (*Cluster, error)

    // Delete deletes a cluster
    Delete(ctx context.Context, name string) error

    // GetKubeconfig retrieves the kubeconfig for a cluster
    GetKubeconfig(ctx context.Context, name string) ([]byte, error)
}
```

### PlatformProvider

Abstracts cloud provider operations:

```go
type PlatformProvider interface {
    // Name returns the provider name (aws, azure, gcp)
    Name() string

    // NetworkManager returns the network manager for this provider
    NetworkManager() NetworkManager

    // ClusterManager returns the cluster manager for this provider
    ClusterManager() ClusterManager

    // Validate validates provider configuration
    Validate(ctx context.Context) error
}
```

## Core Types

### ClusterSpec

Defines cluster configuration:

```go
type ClusterSpec struct {
    Name              string
    Version           string
    Region            string
    VPCConfig         VPCConfig
    NodeGroups        []NodeGroupSpec
    PrivateEndpoint   bool
    PublicEndpoint    bool
    AuthorizedNetworks []string
    Tags              map[string]string
}
```

### Cluster

Represents a running cluster:

```go
type Cluster struct {
    Name           string
    Status         ClusterStatus
    Endpoint       string
    CACertificate  []byte
    Version        string
    NodeGroups     []NodeGroup
    CreatedAt      time.Time
    UpdatedAt      time.Time
}
```

## Implementation Plan

- [ ] Define core interfaces
- [ ] Define cluster types and specs
- [ ] Define network types and specs
- [ ] Implement validation logic
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Generate documentation

## Usage Example

```go
import (
    "context"
    "github.com/yourorg/hera/pkg/platform"
    "github.com/yourorg/hera/pkg/cloud/aws"
)

func main() {
    ctx := context.Background()

    // Initialize AWS provider
    provider := aws.NewProvider(cfg)

    // Get cluster manager
    clusterMgr := provider.ClusterManager()

    // Create cluster
    spec := platform.ClusterSpec{
        Name:    "my-cluster",
        Version: "1.28",
        Region:  "us-east-1",
    }

    cluster, err := clusterMgr.Create(ctx, spec)
    if err != nil {
        panic(err)
    }
}
```
