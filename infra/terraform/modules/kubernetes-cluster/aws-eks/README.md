# AWS EKS Cluster Module

Provisions Amazon Elastic Kubernetes Service (EKS) cluster with managed node groups.

## Resources Created

- EKS Cluster
- EKS Managed Node Groups
- IAM Roles and Policies (cluster and node)
- Security Groups (cluster and node)
- OIDC Provider for IRSA (IAM Roles for Service Accounts)
- Launch templates for node groups
- CloudWatch Log Group for control plane logs

## EKS-Specific Considerations

- **IRSA**: Enable OIDC provider for IAM roles for service accounts
- **VPC CNI**: AWS VPC CNI for pod networking (consider IP exhaustion)
- **Fargate**: Option to add Fargate profiles for serverless nodes
- **Add-ons**: Manage EKS add-ons (vpc-cni, kube-proxy, coredns, ebs-csi-driver)
- **Security Groups**: Separate security groups for cluster and nodes
- **Private Endpoint**: Recommended for production clusters
- **Encryption**: Enable encryption of secrets using KMS
- **Logging**: Enable control plane logging to CloudWatch

## Add-ons to Configure

- `vpc-cni`: Pod networking (consider using prefix delegation for IP optimization)
- `kube-proxy`: Network proxy
- `coredns`: DNS resolution
- `aws-ebs-csi-driver`: EBS volume support for persistent storage
- `aws-efs-csi-driver`: EFS support (optional)

## Node Group Best Practices

- Use managed node groups over self-managed for easier maintenance
- Use launch templates for custom configuration
- Enable automatic updates for node groups
- Use taints and labels for workload segregation
- Consider using Spot instances for dev/non-critical workloads

## Cost Optimization

- Use Spot instances where applicable (70-90% savings)
- Right-size node instance types
- Use Fargate for bursty workloads
- Enable cluster autoscaler to scale down unused nodes
- Use Karpenter as alternative to cluster autoscaler
