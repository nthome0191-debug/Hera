# Kubernetes Manifests

This directory contains Kubernetes manifests organized using Kustomize for managing platform components and configurations.

## Structure

```
k8s/
  base/           # Base configurations (environment-agnostic)
  overlays/       # Environment-specific overlays
    dev/
    staging/
    prod/
```

## Kustomize Pattern

We use Kustomize for managing Kubernetes manifests without templating:
- **base/**: Contains base resource definitions that are environment-agnostic
- **overlays/**: Contains environment-specific patches and customizations

## What Goes Here

This directory is for:
1. Platform-level Kubernetes manifests (not managed by Terraform/Helm)
2. Custom resources and CRDs
3. GitOps configurations (ArgoCD applications)
4. Namespace definitions
5. RBAC policies
6. Network policies
7. Resource quotas and limit ranges
8. ConfigMaps and Secrets (non-sensitive, or sealed)

## What Doesn't Go Here

- Application manifests (this is platform infrastructure only)
- Terraform-managed resources (those stay in infra/terraform)
- Helm charts (use operators/ for custom operators)

## Usage with Kustomize

```bash
# Preview what will be applied
kustomize build overlays/dev

# Apply to cluster
kustomize build overlays/dev | kubectl apply -f -

# Or use kubectl built-in kustomize
kubectl apply -k overlays/dev
```

## Usage with ArgoCD

Once ArgoCD is deployed, these manifests can be managed via GitOps:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-base
spec:
  source:
    repoURL: https://github.com/yourorg/hera
    path: k8s/overlays/dev
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
```

## Future Organization

As the platform grows, consider organizing by component:

```
k8s/
  base/
    argocd/
    monitoring/
    ingress/
    cert-manager/
  overlays/
    dev/
    prod/
```
