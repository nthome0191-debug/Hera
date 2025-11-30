# Platform Libraries

This directory contains reusable Go packages for the Hera platform.

## Purpose

The `pkg/` directory houses shared libraries and utilities used across:
- Kubernetes operators
- CLI tools
- Platform services
- Integration tooling

## Package Organization

```
pkg/
  platform/       # Core platform abstractions
  cloud/          # Cloud provider clients
  k8s/            # Kubernetes utilities
  config/         # Configuration management
  logging/        # Structured logging
  metrics/        # Metrics and monitoring
```

## Guidelines

1. **Public APIs**: Only export what's necessary
2. **No Dependencies on cmd/**: pkg should not depend on cmd packages
3. **Testability**: All packages should be easily testable
4. **Documentation**: Use godoc comments for all public APIs
5. **Versioning**: Consider semantic versioning for stable APIs

## Package Descriptions

### platform/
Core platform abstractions and interfaces for:
- Cluster management
- Platform configuration
- Environment abstractions
- Resource management

### cloud/
Cloud provider client wrappers and utilities:
- AWS clients (EKS, VPC, IAM)
- Azure clients (AKS, VNet, AAD)
- GCP clients (GKE, VPC, IAM)
- Unified interfaces across providers

### k8s/
Kubernetes client utilities:
- Client initialization
- Resource helpers
- Custom resource utilities
- Typed clients for CRDs

### config/
Configuration management:
- Config file parsing
- Environment variable handling
- Validation
- Default values

### logging/
Structured logging utilities:
- Log initialization
- Contextual logging
- Log levels
- Output formatting

### metrics/
Metrics collection and reporting:
- Prometheus metrics
- Custom metrics
- Metric helpers
- Health checks
