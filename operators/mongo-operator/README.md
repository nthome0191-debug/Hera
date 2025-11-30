# MongoDB Operator

A Kubernetes operator for managing MongoDB replica sets and sharded clusters.

## Overview

The MongoDB Operator automates the deployment and management of MongoDB on Kubernetes, supporting:
- Standalone MongoDB instances
- Replica sets for high availability
- Sharded clusters for horizontal scaling
- Automated backups and point-in-time recovery
- Monitoring and performance metrics

## Custom Resources

### MongoDBInstance

Manages a standalone MongoDB instance:

```yaml
apiVersion: database.hera.io/v1alpha1
kind: MongoDBInstance
metadata:
  name: my-mongo
spec:
  version: "7.0"
  storage:
    size: "10Gi"
    storageClassName: "gp3"
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1"
```

### MongoDBReplicaSet

Manages a MongoDB replica set:

```yaml
apiVersion: database.hera.io/v1alpha1
kind: MongoDBReplicaSet
metadata:
  name: my-mongo-rs
spec:
  version: "7.0"
  members: 3
  storage:
    size: "20Gi"
  arbiter:
    enabled: false
```

### MongoDBShardedCluster

Manages a sharded MongoDB cluster:

```yaml
apiVersion: database.hera.io/v1alpha1
kind: MongoDBShardedCluster
metadata:
  name: my-mongo-cluster
spec:
  version: "7.0"
  shards: 3
  configServers: 3
  mongos: 2
```

## Features to Implement

1. **Lifecycle Management**
   - Create/delete MongoDB deployments
   - Version upgrades with minimal downtime
   - Scale replica set members
   - Add/remove shards

2. **High Availability**
   - Replica set configuration
   - Automatic failover
   - Rolling updates
   - Zone-aware deployments

3. **Backup & Recovery**
   - Scheduled backups to S3/GCS/Azure Blob
   - Point-in-time recovery (PITR)
   - Backup encryption
   - Restore operations

4. **Security**
   - TLS/SSL encryption
   - SCRAM authentication
   - RBAC integration
   - Secret management
   - Network encryption

5. **Monitoring**
   - MongoDB Exporter for Prometheus
   - Database metrics
   - Slow query logging
   - Performance insights

6. **Operations**
   - Index management
   - Compaction
   - Arbiter management
   - Connection pooling

## Implementation Plan

### Phase 1: Basic Instance Management
- [ ] CRD definitions for MongoDBInstance
- [ ] Controller for standalone MongoDB
- [ ] StatefulSet generation
- [ ] Service creation
- [ ] Initialization scripts

### Phase 2: Replica Sets
- [ ] CRD for MongoDBReplicaSet
- [ ] Replica set initialization
- [ ] Member addition/removal
- [ ] Automatic failover handling

### Phase 3: Sharding
- [ ] CRD for MongoDBShardedCluster
- [ ] Config servers setup
- [ ] Shard deployment
- [ ] Mongos router configuration

### Phase 4: Backup & Recovery
- [ ] Backup CRD
- [ ] S3/GCS/Azure integration
- [ ] Scheduled backups
- [ ] Restore operations

### Phase 5: Advanced Operations
- [ ] Version upgrades
- [ ] Monitoring integration
- [ ] Performance tuning
- [ ] Multi-region support

## Dependencies

- Kubernetes 1.25+
- Operator SDK or Kubebuilder
- MongoDB 6.0+
- S3-compatible storage (for backups)

## Installation

```bash
# Install CRDs
kubectl apply -f config/crd/

# Deploy operator
kubectl apply -f config/manager/

# Create a MongoDB replica set
kubectl apply -f config/samples/database_v1alpha1_mongodbreplicaset.yaml
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
make docker-build docker-push IMG=your-registry/mongo-operator:tag
```
