# Base Kubernetes Manifests

Environment-agnostic base Kubernetes resources. These are the foundation that overlays will customize.

## Contents

This directory should contain:

### Namespaces
- Platform system namespaces
- Monitoring namespace
- Security namespace
- Ingress namespace

### RBAC
- ClusterRoles for platform services
- ServiceAccounts for platform components
- RoleBindings and ClusterRoleBindings

### Network Policies
- Default deny policies
- Allow policies for platform components
- Namespace isolation policies

### Resource Quotas & Limits
- Default resource quotas for namespaces
- Default limit ranges for containers

### ConfigMaps
- Platform-wide configuration
- Feature flags
- Common environment variables

## Kustomization

The base directory should have a `kustomization.yaml` that lists all resources:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespaces.yaml
  - rbac.yaml
  - network-policies.yaml
  - resource-quotas.yaml
```

## Guidelines

1. Keep base resources generic and environment-agnostic
2. Use labels consistently for resource organization
3. Avoid hardcoded values - use overlays for customization
4. Document why each resource exists
5. Use proper RBAC - principle of least privilege
