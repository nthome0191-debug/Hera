# Secrets Operator

A Kubernetes operator for synchronizing secrets from external secret management systems.

## Overview

The Secrets Operator provides a unified way to inject secrets from external sources into Kubernetes, supporting:
- AWS Secrets Manager
- Azure Key Vault
- Google Cloud Secret Manager
- HashiCorp Vault
- Automatic secret rotation
- Secret versioning

## Custom Resources

### ExternalSecret

Defines a mapping between an external secret and a Kubernetes Secret:

```yaml
apiVersion: secrets.hera.io/v1alpha1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: default
spec:
  backend: aws-secrets-manager
  region: us-east-1
  data:
    - key: prod/db/credentials
      name: password
      property: password
  target:
    name: db-secret
    creationPolicy: Owner
```

### SecretStore

Configures connection to an external secret backend:

```yaml
apiVersion: secrets.hera.io/v1alpha1
kind: SecretStore
metadata:
  name: aws-backend
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        workloadIdentity:
          serviceAccountRef:
            name: secrets-operator
```

## Supported Backends

### AWS Secrets Manager
- Uses IRSA (IAM Roles for Service Accounts)
- Supports secret rotation
- Version pinning

### Azure Key Vault
- Uses Workload Identity
- Supports certificates and keys
- Automatic renewal

### Google Cloud Secret Manager
- Uses Workload Identity
- Multi-region secrets
- Version management

### HashiCorp Vault
- Token or Kubernetes auth
- Dynamic secrets
- PKI integration

## Features to Implement

1. **Secret Synchronization**
   - Fetch secrets from external sources
   - Create/update Kubernetes Secrets
   - Automatic reconciliation
   - Batch operations

2. **Secret Rotation**
   - Detect external secret changes
   - Update Kubernetes Secrets
   - Trigger pod restarts (optional)
   - Rotation policies

3. **Security**
   - Workload Identity integration
   - Secret encryption at rest
   - Audit logging
   - RBAC integration

4. **Multi-Backend Support**
   - Provider abstraction
   - Pluggable architecture
   - Cross-provider secret templating

5. **Advanced Features**
   - Secret templating (combine multiple sources)
   - Secret transformation
   - Conditional secret creation
   - Secret validation

## Implementation Plan

### Phase 1: Core Functionality
- [ ] CRD definitions (ExternalSecret, SecretStore)
- [ ] Basic controller logic
- [ ] Kubernetes Secret creation
- [ ] AWS Secrets Manager integration

### Phase 2: Multi-Cloud Support
- [ ] Azure Key Vault integration
- [ ] GCP Secret Manager integration
- [ ] Provider abstraction layer

### Phase 3: Advanced Features
- [ ] Secret rotation
- [ ] Secret templating
- [ ] Version management
- [ ] Drift detection

### Phase 4: Vault Integration
- [ ] HashiCorp Vault support
- [ ] Dynamic secrets
- [ ] PKI integration
- [ ] Database credential rotation

### Phase 5: Operations
- [ ] Monitoring and metrics
- [ ] Audit logging
- [ ] Performance optimization
- [ ] Multi-tenancy support

## Security Considerations

1. **Authentication**: Use cloud workload identity (IRSA, Workload Identity)
2. **Encryption**: Secrets encrypted in etcd
3. **RBAC**: Restrict access to ExternalSecret resources
4. **Audit**: Log all secret operations
5. **Rotation**: Automatic rotation policies

## Dependencies

- Kubernetes 1.25+
- Operator SDK or Kubebuilder
- Cloud provider SDKs (AWS, Azure, GCP)
- Vault SDK (optional)

## Installation

```bash
# Install CRDs
kubectl apply -f config/crd/

# Create SecretStore
kubectl apply -f config/samples/secretstore.yaml

# Deploy operator
kubectl apply -f config/manager/

# Create ExternalSecret
kubectl apply -f config/samples/secrets_v1alpha1_externalsecret.yaml
```

## Development

```bash
# Generate manifests
make manifests

# Run tests
make test

# Run locally (requires cloud credentials)
make run

# Build and push image
make docker-build docker-push IMG=your-registry/secrets-operator:tag
```

## Comparison with External Secrets Operator

This is a custom implementation for Hera. Consider using the existing [External Secrets Operator](https://external-secrets.io/) as an alternative if it meets your needs.
