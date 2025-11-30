# Kubernetes Operators

This directory contains custom Kubernetes operators built for the Hera platform.

## What are Operators?

Operators are Kubernetes extensions that use custom resources to manage applications and their components. They follow the Operator Pattern, extending Kubernetes to manage complex stateful applications.

## Operator Framework

Operators in this directory should be built using:
- **Operator SDK** (recommended): Framework for building operators
- **Kubebuilder**: Alternative operator framework
- **Language**: Go (primary), Python (via Kopf)

## Operators in Hera

### Current Operators
- **redis-operator**: Manages Redis clusters and instances
- **mongo-operator**: Manages MongoDB replica sets and clusters
- **secrets-operator**: Manages external secrets synchronization

### Future Operators
- **backup-operator**: Automated backup management
- **certificate-operator**: Certificate lifecycle management
- **config-operator**: Configuration management across environments

## Operator Structure

Each operator should follow this structure:

```
operator-name/
  api/              # CRD definitions and types
  controllers/      # Controller logic
  config/           # RBAC, CRDs, manager deployment
    crd/           # CRD YAML files
    rbac/          # RBAC manifests
    manager/       # Operator deployment
  docs/             # Operator documentation
  Dockerfile        # Container image build
  Makefile          # Build and deployment automation
  README.md         # Operator-specific documentation
```

## Building Operators

```bash
cd operators/redis-operator

# Generate CRDs
make manifests

# Build operator binary
make build

# Build container image
make docker-build

# Deploy to cluster
make deploy
```

## Testing Operators

Each operator should have:
1. Unit tests for controller logic
2. Integration tests using envtest
3. E2E tests against real clusters
4. Example CR manifests in `config/samples/`

## Deployment

Operators can be deployed via:
1. **Direct kubectl apply**: For development
2. **Helm charts**: For production
3. **ArgoCD**: For GitOps management (recommended)

## Best Practices

1. **Idempotency**: Operators should be idempotent
2. **Reconciliation**: Handle partial failures gracefully
3. **Status Updates**: Keep CR status up to date
4. **Finalizers**: Clean up resources properly
5. **Events**: Emit events for important state changes
6. **Logging**: Use structured logging
7. **Metrics**: Expose Prometheus metrics
8. **Documentation**: Document CRD spec and examples
