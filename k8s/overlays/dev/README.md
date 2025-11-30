# Development Overlay

Environment-specific customizations for development clusters.

## Purpose

This overlay applies dev-specific patches and configurations to the base manifests:
- Lower resource limits
- More permissive policies for testing
- Debug-friendly configurations
- Development tools and utilities

## Kustomization

The dev overlay references base and applies patches:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patchesStrategicMerge:
  - resource-quotas-patch.yaml
  - network-policies-patch.yaml

configMapGenerator:
  - name: platform-config
    literals:
      - ENVIRONMENT=dev
      - LOG_LEVEL=debug
```

## Dev-Specific Customizations

1. **Resource Quotas**: Lower limits for cost optimization
2. **Network Policies**: More permissive for easier debugging
3. **Logging**: Debug level logging enabled
4. **Monitoring**: Basic monitoring without long-term retention
5. **Tools**: Development utilities and debug tools

## Usage

```bash
kubectl apply -k overlays/dev
```
