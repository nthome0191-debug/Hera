# Platform Base Module

Provides foundational platform components and configurations that should be deployed to every Kubernetes cluster.

## Purpose

This module sets up essential platform services and configurations that are prerequisites for other platform components and applications.

## Components to Include

### Essential Services
- **Metrics Server**: For HPA and resource metrics
- **Cluster Autoscaler**: For automatic node scaling (cloud-specific configurations)
- **CoreDNS Configuration**: Custom DNS settings if needed
- **Storage Classes**: Default and custom storage classes

### Security & Compliance
- **Pod Security Standards**: Enforce pod security policies
- **Network Policies**: Default deny policies
- **Resource Quotas**: Default quotas for namespaces
- **Limit Ranges**: Default limits for containers

### Observability Foundation
- **Logging Configuration**: Fluentd/Fluent-bit for log aggregation
- **Metrics Configuration**: OpenTelemetry collector
- **Tracing Configuration**: Jaeger/Tempo setup

### Platform Namespaces
- `platform-system`: Core platform components
- `monitoring`: Monitoring and observability
- `security`: Security tools and policies
- `ingress-system`: Ingress controllers
- `cert-manager`: Certificate management
- `argocd`: GitOps platform

## Implementation Approach

This module can be implemented using:
1. **Terraform Kubernetes Provider**: For basic resources (namespaces, config maps, etc.)
2. **Helm Provider**: For deploying charts (metrics-server, cluster-autoscaler, etc.)
3. **Kubectl Provider**: For custom resources and CRDs

## Module Interface

### Inputs
- `cluster_name`: Kubernetes cluster name
- `cluster_endpoint`: Cluster API endpoint
- `cluster_ca_certificate`: Cluster CA certificate
- `kubeconfig`: Kubeconfig for cluster access
- `cloud_provider`: Cloud provider (aws, azure, gcp)
- `environment`: Environment name
- `enable_cluster_autoscaler`: Enable cluster autoscaler
- `enable_metrics_server`: Enable metrics server

### Outputs
- `platform_namespaces`: List of created platform namespaces
- `storage_class_names`: Available storage class names

## Dependencies

This module depends on:
- A running Kubernetes cluster
- Cluster authentication credentials
- Cloud-specific IAM roles/service accounts for workload identity
