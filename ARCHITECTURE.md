# Hera Architecture

This document describes the architecture and design principles of the Hera platform.

## Overview

Hera is a cloud-agnostic infrastructure platform for provisioning and managing Kubernetes clusters across AWS, Azure, and GCP. It follows a layered architecture with clear separation of concerns.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│                   (Not part of Hera)                         │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Platform Layer                            │
│  ┌──────────────┬──────────────┬──────────────────────────┐ │
│  │   ArgoCD     │  Argo        │  Custom Operators        │ │
│  │   (GitOps)   │  Workflows   │  (Redis, Mongo, Secrets) │ │
│  └──────────────┴──────────────┴──────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                  Kubernetes Layer                            │
│  ┌──────────────┬──────────────┬──────────────────────────┐ │
│  │   AWS EKS    │  Azure AKS   │      GCP GKE             │ │
│  └──────────────┴──────────────┴──────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Network Layer                              │
│  ┌──────────────┬──────────────┬──────────────────────────┐ │
│  │   AWS VPC    │  Azure VNet  │      GCP VPC             │ │
│  └──────────────┴──────────────┴──────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│                   Cloud Provider Layer                       │
│             AWS / Azure / GCP                                │
└─────────────────────────────────────────────────────────────┘
```

## Component Architecture

### 1. Infrastructure (Terraform)

```
infra/terraform/
├── modules/              # Reusable modules
│   ├── network/         # VPC/networking modules
│   │   ├── aws/
│   │   ├── azure/
│   │   └── gcp/
│   ├── kubernetes-cluster/
│   │   ├── aws-eks/
│   │   ├── azure-aks/
│   │   └── gcp-gke/
│   └── platform/
│       └── base/
└── envs/                # Environment compositions
    ├── dev/
    ├── staging/
    └── prod/
```

**Design Principles:**
- **Cloud-Specific Implementation**: Each cloud has its own module implementation
- **Consistent Interface**: All modules expose the same input/output contract
- **Composable**: Environments compose modules without business logic
- **Stateless**: Modules are stateless and idempotent

### 2. Kubernetes Manifests

```
k8s/
├── base/                # Base manifests
│   ├── namespaces
│   ├── rbac
│   └── network-policies
└── overlays/            # Environment overlays
    ├── dev/
    └── prod/
```

**Design Principles:**
- **Kustomize-based**: Use Kustomize for manifest management
- **Environment Separation**: Overlays for environment-specific customization
- **GitOps Ready**: Designed for ArgoCD integration

### 3. Operators

```
operators/
├── redis-operator/
├── mongo-operator/
└── secrets-operator/
```

**Design Principles:**
- **Operator Pattern**: Follow Kubernetes operator best practices
- **Custom Resources**: Define CRDs for managed resources
- **Reconciliation**: Continuous reconciliation of desired state
- **Cloud-Agnostic**: Work across all cloud providers

### 4. Go Packages and CLI

```
pkg/                     # Shared libraries
└── platform/           # Core abstractions

cmd/                     # CLI tools
└── clusterctl/         # Cluster management CLI
```

**Design Principles:**
- **Abstraction**: Platform package provides cloud-agnostic interfaces
- **Composition**: CLI tools use platform packages
- **Extensibility**: Easy to add new cloud providers

## Data Flow

### Cluster Creation Flow

1. **User Initiates**: Via `clusterctl` or Terraform directly
2. **Network Module**: Creates VPC, subnets, NAT gateways
3. **Cluster Module**: Creates Kubernetes cluster using outputs from network module
4. **Platform Module**: Installs base platform components (metrics-server, autoscaler)
5. **K8s Manifests**: Applied via Kustomize or ArgoCD
6. **Operators**: Deployed to manage stateful applications

### Secret Management Flow

1. **ExternalSecret CR**: Created in cluster
2. **Secrets Operator**: Watches ExternalSecret resources
3. **Cloud Provider**: Operator fetches secret from cloud provider's secret service
4. **Kubernetes Secret**: Operator creates/updates Kubernetes Secret
5. **Application**: Consumes secret via volume mount or env var

## Security Architecture

### Network Security

- **Private Clusters**: Kubernetes API on private endpoint by default
- **Network Policies**: Default deny policies with explicit allow rules
- **Subnet Isolation**: Separation between public and private subnets
- **NAT Gateways**: Private subnets use NAT for internet egress

### Identity and Access

- **Workload Identity**:
  - AWS: IRSA (IAM Roles for Service Accounts)
  - Azure: Workload Identity
  - GCP: Workload Identity
- **RBAC**: Kubernetes RBAC for all platform components
- **Secrets**: External secret management (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)

### Encryption

- **At Rest**: Kubernetes secrets encrypted with KMS
- **In Transit**: TLS for all communications
- **Network**: VPC encryption where available

## High Availability

### Network HA

- **Multi-AZ**: Resources distributed across availability zones
- **NAT Redundancy**: NAT gateway per AZ in production
- **Load Balancing**: Cloud load balancers for ingress

### Cluster HA

- **Control Plane**: Managed control plane (HA by cloud provider)
- **Worker Nodes**: Distributed across AZs
- **Autoscaling**: Cluster autoscaler for node scaling

### Platform HA

- **Operators**: Multiple replicas with leader election
- **Stateful Services**: Replica sets for databases
- **GitOps**: ArgoCD HA configuration

## Observability

### Metrics

- **Prometheus**: Metrics collection
- **Grafana**: Metrics visualization
- **Custom Metrics**: Operator-specific metrics

### Logging

- **Control Plane Logs**: Cloud provider logging (CloudWatch, Azure Monitor, Cloud Logging)
- **Application Logs**: Centralized logging (Fluentd/Fluent-bit)
- **Audit Logs**: Kubernetes audit logging enabled

### Tracing

- **OpenTelemetry**: Distributed tracing
- **Jaeger/Tempo**: Trace storage and analysis

## Disaster Recovery

### Backup Strategy

- **Cluster State**: Terraform state in remote backend
- **Kubernetes Resources**: GitOps repository is source of truth
- **Stateful Data**: Operator-managed backups to cloud storage
- **Secrets**: Stored in cloud secret managers

### Recovery Procedures

1. **Cluster Recreation**: Terraform apply from state
2. **Platform Restoration**: ArgoCD sync from Git
3. **Data Restoration**: Operator-managed restore operations

## Cost Optimization

### Compute

- **Spot Instances**: Dev environments use spot/preemptible instances
- **Autoscaling**: Aggressive scale-down in dev, conservative in prod
- **Right-sizing**: Instance types appropriate for workload

### Networking

- **Single NAT**: Dev uses single NAT gateway
- **VPC Endpoints**: Use VPC endpoints to reduce data transfer
- **Private Access**: Reduce internet egress costs

### Storage

- **Lifecycle Policies**: Automated cleanup of old backups
- **Compression**: Compress backups before storage
- **Storage Classes**: Appropriate storage classes for workloads

## Future Enhancements

### Multi-Region

- Support for multi-region deployments
- Cross-region failover
- Global load balancing

### Advanced Platform Services

- Service mesh (Istio/Linkerd)
- Advanced observability (Thanos, Loki)
- Cost management and optimization tools
- Policy enforcement (OPA/Gatekeeper)

### Improved Automation

- Self-healing capabilities
- Predictive scaling
- Automated upgrades with rollback
- Chaos engineering integration

## Design Principles Summary

1. **Cloud-Agnostic**: Write once, deploy anywhere
2. **Modular**: Clear separation of concerns
3. **Declarative**: Infrastructure as Code
4. **GitOps**: Git as single source of truth
5. **Secure by Default**: Security built-in, not bolted on
6. **Observable**: Comprehensive monitoring and logging
7. **Resilient**: High availability and disaster recovery
8. **Cost-Aware**: Optimize for cost without sacrificing reliability
9. **Maintainable**: Clear structure, good documentation
10. **Extensible**: Easy to add new features and providers
