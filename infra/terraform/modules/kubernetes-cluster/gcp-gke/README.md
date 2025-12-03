# GCP GKE Cluster Module

🔄 **STATUS: PLANNED - NOT YET IMPLEMENTED**

This module is a **stub/placeholder** for future GCP GKE implementation. The AWS EKS module (`../aws-eks/`) is production-ready and serves as the reference implementation.

## Planned Features

This module will provision Google Kubernetes Engine (GKE) infrastructure including:

## Resources Created

- GKE Cluster
- Node Pools
- Service Accounts for nodes
- IAM bindings
- Workload Identity bindings

## GKE-Specific Considerations

- **GKE Autopilot vs Standard**: Standard mode for more control
- **Workload Identity**: Enable for pod-level GCP access (replaces node service accounts)
- **VPC-Native Cluster**: Use alias IPs for better networking
- **Private Cluster**: Private nodes with optional private endpoint
- **Binary Authorization**: Enforce deployment policies
- **Release Channels**: Use release channels for automatic updates
- **Shielded Nodes**: Enable shielded GKE nodes for security
- **Network Policy**: Enable network policy (Calico)
- **Cloud Logging/Monitoring**: Integration with Cloud Operations

## Add-ons to Configure

- `http_load_balancing`: GKE Ingress controller
- `horizontal_pod_autoscaling`: HPA support
- `network_policy_config`: Network policy support
- `gcp_filestore_csi_driver`: Filestore CSI driver
- `gce_persistent_disk_csi_driver`: Persistent disk CSI driver

## Node Pool Best Practices

- System node pool: For system components
- Use preemptible nodes for dev/non-critical workloads
- Enable autoscaling and autorepair
- Use taints and labels for workload segregation
- Distribute nodes across zones for HA
- Use node auto-provisioning for dynamic scaling

## Cost Optimization

- Use preemptible VMs (up to 80% savings)
- Consider GKE Autopilot for automatic optimization
- Right-size machine types
- Use committed use discounts
- Enable cluster autoscaler
- Use node auto-provisioning for bin packing
