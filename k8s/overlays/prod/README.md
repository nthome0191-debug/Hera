# Production Overlay

Environment-specific customizations for production clusters.

## Purpose

This overlay applies production-grade configurations to the base manifests:
- Production resource limits
- Strict security policies
- Enhanced monitoring and logging
- High availability configurations

## Kustomization

The prod overlay references base and applies production patches:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patchesStrategicMerge:
  - resource-quotas-patch.yaml
  - network-policies-patch.yaml
  - pod-security-patch.yaml

configMapGenerator:
  - name: platform-config
    literals:
      - ENVIRONMENT=prod
      - LOG_LEVEL=info
```

## Production-Specific Customizations

1. **Resource Quotas**: Production-appropriate limits
2. **Network Policies**: Strict isolation between namespaces
3. **Pod Security**: Enforced restricted security standards
4. **Logging**: Info level logging with long-term retention
5. **Monitoring**: Comprehensive monitoring with alerting
6. **Backup**: Automated backup configurations

## Change Management

All production changes must:
1. Be reviewed via pull request
2. Be tested in dev/staging first
3. Be applied during maintenance windows
4. Have rollback procedures documented

## Usage

```bash
# Always review before applying
kubectl diff -k overlays/prod

# Apply during maintenance window
kubectl apply -k overlays/prod
```
