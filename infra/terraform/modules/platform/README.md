# Platform Modules

Platform modules contain shared, cloud-agnostic platform components and configurations that run on top of Kubernetes clusters.

## Purpose

These modules handle platform-level concerns that are independent of the underlying cloud provider, such as:
- Common Kubernetes resources and configurations
- Platform service configurations
- Shared policies and standards
- Platform-wide monitoring and observability
- GitOps configurations

## Module Structure

- **base/**: Foundation platform components that every cluster needs

## Future Modules

As Hera evolves, additional platform modules will be added:
- **argocd/**: ArgoCD GitOps platform
- **argo-workflows/**: Argo Workflows for CI/CD
- **buildkit/**: BuildKit for container image building
- **monitoring/**: Prometheus, Grafana, Loki stack
- **ingress/**: Ingress controller configurations
- **cert-manager/**: Certificate management
- **external-secrets/**: External secrets management
