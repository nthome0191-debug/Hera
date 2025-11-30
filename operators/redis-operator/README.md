# Redis Operator

A Kubernetes operator for managing Redis clusters and instances.

## Overview

The Redis Operator simplifies the deployment and management of Redis on Kubernetes, supporting:
- Standalone Redis instances
- Redis Sentinel for high availability
- Redis Cluster for horizontal scaling
- Automated backups and recovery
- Monitoring and metrics

## Custom Resources

### RedisInstance

Manages a standalone Redis instance:

```yaml
apiVersion: cache.hera.io/v1alpha1
kind: RedisInstance
metadata:
  name: my-redis
spec:
  version: "7.2"
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  persistence:
    enabled: true
    size: "1Gi"
    storageClassName: "gp3"
```

### RedisCluster

Manages a Redis Cluster:

```yaml
apiVersion: cache.hera.io/v1alpha1
kind: RedisCluster
metadata:
  name: my-redis-cluster
spec:
  version: "7.2"
  masters: 3
  replicasPerMaster: 1
  resources:
    requests:
      memory: "512Mi"
      cpu: "200m"
```

## Features to Implement

1. **Lifecycle Management**
   - Creation and deletion of Redis instances
   - Version upgrades with zero downtime
   - Scaling up/down

2. **High Availability**
   - Redis Sentinel support
   - Automatic failover
   - Split-brain protection

3. **Backup & Recovery**
   - Scheduled RDB snapshots
   - AOF persistence configuration
   - Point-in-time recovery

4. **Monitoring**
   - Prometheus metrics exporter
   - Health checks and liveness probes
   - Performance metrics

5. **Security**
   - TLS encryption
   - ACL management
   - Password rotation

## Implementation Plan

### Phase 1: Basic Instance Management
- [ ] CRD definitions for RedisInstance
- [ ] Controller for standalone Redis
- [ ] StatefulSet generation
- [ ] Service and ConfigMap creation
- [ ] Basic health checks

### Phase 2: High Availability
- [ ] Redis Sentinel support
- [ ] Automatic failover handling
- [ ] Master/replica topology

### Phase 3: Redis Cluster
- [ ] CRD for RedisCluster
- [ ] Cluster initialization
- [ ] Slot distribution
- [ ] Scaling operations

### Phase 4: Operations
- [ ] Backup automation
- [ ] Version upgrades
- [ ] Monitoring integration
- [ ] Metrics and alerting

## Dependencies

- Kubernetes 1.25+
- Operator SDK or Kubebuilder
- Redis 6.2+

## Installation

```bash
# Install CRDs
kubectl apply -f config/crd/

# Deploy operator
kubectl apply -f config/manager/

# Create a Redis instance
kubectl apply -f config/samples/cache_v1alpha1_redisinstance.yaml
```

## Development

```bash
# Generate manifests
make manifests

# Run tests
make test

# Run locally
make run

# Build and push image
make docker-build docker-push IMG=your-registry/redis-operator:tag
```
