# Azure AKS Cluster Module

🔄 **STATUS: PLANNED - NOT YET IMPLEMENTED**

This module is a **stub/placeholder** for future Azure AKS implementation. The AWS EKS module (`../aws-eks/`) is production-ready and serves as the reference implementation.

## Planned Features

This module will provision Azure Kubernetes Service (AKS) infrastructure including:

## Resources Created

- AKS Cluster
- Node Pools (system and user)
- Managed Identity for cluster
- Role Assignments
- User Assigned Identity for kubelet
- Log Analytics Workspace (for monitoring)

## AKS-Specific Considerations

- **Managed Identity**: Use managed identity instead of service principals
- **Azure CNI vs Kubenet**: Azure CNI for production (better network performance)
- **Network Policy**: Support for Azure Network Policy or Calico
- **Workload Identity**: Enable workload identity for pod-level Azure access
- **Azure Monitor**: Integration with Azure Monitor for container insights
- **Azure AD Integration**: Enable Azure AD for RBAC
- **Private Cluster**: Option to make API server private
- **Authorized IP Ranges**: Restrict API server access

## Add-ons to Configure

- `monitoring`: Container insights
- `azure-policy`: Azure Policy for Kubernetes
- `http_application_routing`: Simple ingress (dev only)
- `azure-keyvault-secrets-provider`: Key Vault CSI driver

## Node Pool Best Practices

- System node pool: For system components (separate from workloads)
- User node pools: For application workloads
- Use availability zones for high availability
- Enable autoscaling on node pools
- Use taints and labels for workload segregation
- Consider Spot node pools for dev/non-critical workloads

## Cost Optimization

- Use Spot VMs where applicable (up to 90% savings)
- Right-size node VM SKUs
- Use autoscaling to scale down unused nodes
- Stop/start clusters for dev environments
- Use Azure Dev/Test pricing if applicable
