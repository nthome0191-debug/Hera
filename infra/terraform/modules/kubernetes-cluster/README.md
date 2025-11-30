# Kubernetes Cluster Modules

This directory contains cloud-specific Kubernetes cluster modules. Each cloud provider has its own managed Kubernetes service with a consistent interface.

## Module Interface Contract

All Kubernetes cluster modules must expose the same input/output interface to maintain cloud-agnostic composition at the environment level.

### Required Inputs
- `cluster_name` (string): Name of the Kubernetes cluster
- `environment` (string): Environment name (dev, staging, prod)
- `region` (string): Cloud region for deployment
- `kubernetes_version` (string): Kubernetes version to deploy
- `vpc_id` (string): VPC/VNet ID from network module
- `private_subnet_ids` (list): Private subnet IDs for worker nodes
- `public_subnet_ids` (list): Public subnet IDs for load balancers
- `node_groups` (map): Configuration for node groups/pools
- `enable_private_endpoint` (bool): Enable private cluster endpoint
- `enable_public_endpoint` (bool): Enable public cluster endpoint
- `authorized_networks` (list): CIDRs allowed to access public endpoint
- `tags` (map): Common tags to apply to all resources

### Required Outputs
- `cluster_id`: Cluster identifier
- `cluster_endpoint`: Kubernetes API endpoint
- `cluster_ca_certificate`: Cluster CA certificate (base64 encoded)
- `cluster_security_group_id`: Security group ID for cluster
- `node_security_group_id`: Security group ID for nodes
- `kubeconfig`: Kubeconfig content for cluster access
- `oidc_provider_arn`: OIDC provider ARN (for IRSA/workload identity)

## Node Group Configuration Schema

Each cloud implementation should support:
```hcl
node_groups = {
  "group-name" = {
    min_size       = 1
    max_size       = 10
    desired_size   = 3
    instance_types = ["t3.medium"]
    disk_size      = 100
    labels         = {}
    taints         = []
  }
}
```

## Implementation Guidelines

1. **Managed Services**: Use managed Kubernetes services (EKS, AKS, GKE)
2. **Private Clusters**: Default to private endpoints for security
3. **RBAC**: Enable RBAC by default
4. **Pod Security**: Enable pod security standards
5. **Logging**: Enable control plane logging
6. **Monitoring**: Enable metrics and monitoring
7. **Auto-scaling**: Support cluster autoscaler
8. **Workload Identity**: Enable IRSA/Workload Identity for pod IAM
9. **Network Policies**: Enable network policy support
10. **Add-ons**: Include essential add-ons (CoreDNS, kube-proxy, etc.)

## Cloud Implementations

- **aws-eks/**: Amazon Elastic Kubernetes Service
- **azure-aks/**: Azure Kubernetes Service
- **gcp-gke/**: Google Kubernetes Engine
