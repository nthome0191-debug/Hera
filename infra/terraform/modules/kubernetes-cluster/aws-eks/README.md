# Hera - AWS EKS Cluster Module

This module provisions a **production-ready Amazon EKS cluster** for Hera on top of the AWS network module.

It is designed to be:

- **Managed** - uses Amazon EKS for the control plane  
- **Secure** - IRSA, encrypted volumes, SG separation, private endpoints  
- **Flexible** - multiple node groups, taints, labels, instance types  
- **Cost-aware** - dev and prod modes via configuration  
- **Ephemeral-friendly** - safe to destroy/recreate dev/stage clusters  

---

# What This Module Creates

## 1. CloudWatch Log Group — Control Plane Logs

**Resource:** `aws_cloudwatch_log_group.eks_cluster`  
Stores control-plane logs:
- `api`, `audit`, `authenticator`, `controllerManager`, `scheduler`  

**Config:**
- `cluster_log_retention_days`

**Cost:** low (typically $1-$10/month)

---

## 2. EKS Cluster IAM Role

**Resources:**
- `aws_iam_role.cluster`
- Attachments:  
  `AmazonEKSClusterPolicy`, `AmazonEKSVPCResourceController`

Required for the control plane to manage networking resources.

---

## 3. Cluster Security Group

**Resource:** `aws_security_group.cluster`  
Allows:
- Nodes → API Server (HTTPS)
- API Server → Nodes  
- All outbound traffic

Protects the control plane traffic path.

---

## 4. The EKS Cluster (Control Plane)

**Resource:** `aws_eks_cluster.main`

Key configs:
- `cluster_name`
- `region`
- `kubernetes_version`
- `vpc_id`
- `private_subnet_ids`
- `public_subnet_ids` (optional)
- Private/public API endpoints
- Control-plane logs
- KMS encryption support

**Cost:** ~**$72/month** per control plane (fixed).

---

## 5. OIDC Provider for IRSA (IAM Roles for Service Accounts)

**Resources:**
- `data.tls_certificate.cluster`
- `aws_iam_openid_connect_provider.cluster`

Enables Kubernetes pods to assume IAM roles without EC2 instance profiles.

**Cost:** free  
**Recommendation:** always enabled.

---

## 6. Node IAM Role & Node Security Group

**Resources:**
- IAM: `aws_iam_role.node` (with EKS worker policies)
- SG: `aws_security_group.node`

Allows:
- Node ↔ Node communication  
- Node ↔ Control plane  
- Pods ↔ External AWS services (via IRSA or node role)

---

## 7. Node Launch Templates

**Resource:** `aws_launch_template.node`  
Configures:
- Root volume  
- Instance metadata (IMDSv2)  
- Tags  
- Monitoring  

Used automatically by EKS-managed node groups.

---

## 8. EKS Managed Node Groups

**Resource:** `aws_eks_node_group.main`

Configurable per node group:
- `instance_types`
- `capacity_type` (ON_DEMAND / SPOT)
- Desired/min/max sizes
- Labels & taints  
- Disk size  
- Multi-AZ placement  

**Cost:** dominated by EC2 instances.

---

## 9. EKS Addons

Core addons:
- `vpc-cni` (AWS CNI)
- `kube-proxy`
- `coredns`

Optional:
- EBS CSI driver (default: enabled)
- Custom addons via `addons` map  

Managed as `aws_eks_addon` resources.

---

## 10. IRSA Role — EBS CSI Driver

**Resources:**  
- Dedicated IAM role for the controller  
- Attached policy for provisioning EBS volumes

Required for:
- PersistentVolumes backed by AWS EBS  

---

## 11. IRSA Role — Cluster Autoscaler

Optional, enabled via:
- `enable_cluster_autoscaler = true`

Creates:
- IAM role for CA  
- IAM policy for scaling node groups

---

# Inputs Overview (Most Important)

- `cluster_name`, `environment`, `region`
- `vpc_id`, `private_subnet_ids`, `public_subnet_ids`
- `kubernetes_version` (default `"1.32"`)
- Endpoint settings:  
  - `enable_private_endpoint`  
  - `enable_public_endpoint`  
  - `authorized_networks`
- `enable_irsa` (default: true)
- `node_groups` (map)
- Logging configurations  
- Addons & driver toggles  
- `enable_cluster_encryption`, `kms_key_id`
- `tags`

---

# Dev vs Prod Profiles

## Dev / Early Stage

Recommended:
- 1 small SPOT node group (`t3.medium` or similar)
- 1-2 nodes
- Public API endpoint with restricted CIDR  
- Log retention = 7 days  
- EBS CSI = optional  
- Autoscaler = optional  
- Easy to destroy nightly  

## Production

Recommended:
- Private endpoint only (or restricted public)
- Multi-AZ node groups  
- Separate node groups:
  - On-demand system  
  - Spot application nodes  
- Autoscaler enabled  
- EBS CSI enabled  
- KMS encryption enabled  
- Log retention 14-30 days  
- IRSA for all pods with AWS access  

---

# Approximate Monthly Cost (Small Dev Cluster)

- EKS control plane: **~$72**
- 2 × `t3.medium` nodes: **$60-$80**
- CloudWatch logs: **$1-$5**

**Total:** ~**$130-$160/month**

For production clusters, cost scales with node count and instance size.

---

# AWS EKS Architecture Components 

## Kubernetes Node Internals

### **kubelet**
- Runs on every EC2 worker node.
- Manages pods, containers, volumes, liveness probes, etc.
- Talks to the API Server (secure TLS).  

Without kubelet, no pods can run.

---

### **kube-proxy**
- Implements Service → Pod networking rules.
- Programs iptables or IPVS rules on nodes.
- Routes ClusterIP service traffic to pods.

Deployed as a DaemonSet managed as an EKS Addon.

---

## DNS & Networking

### **CoreDNS**
- Internal DNS server for Kubernetes.
- Resolves:
  - `svc.namespace.svc.cluster.local`
  - External names via upstream DNS

If CoreDNS is unhealthy → the entire cluster breaks.

---

### **AWS VPC CNI (`aws-node`)**
This is the **CNI plugin** responsible for Pod networking:
- Each pod receives a **real VPC IP**.  
- CNI manages **ENIs** (Elastic Network Interfaces) and **Pod IPs**.  
- Node instance type limits how many ENIs & Pod IPs you can allocate.

**Example:**  
`t3.medium` → ~17 pods per node (ENI/IP limits)

---

## ENIs (Elastic Network Interfaces)
AWS attaches ENIs to each EC2 node:
- Each ENI has a number of IPv4 addresses.
- Each Pod consumes a real VPC IP address.
- Pod density is limited by ENI/IP limits.

This is why instance types matter for Kubernetes capacity.

---

# What Happens After Terraform Creates the EKS Cluster? (Day-1 Guide)

These are the steps to begin using your new EKS cluster.

## 1. Configure `kubectl`

```
aws eks update-kubeconfig \
  --region <region> \
  --name <cluster_name>
```
```
kubectl config rename-context <long name> <friendly name>
```

Verify:
```
kubectl get nodes
```

---

## 2. Verify System Components

```
kubectl get pods -n kube-system
```

Expect:
- `coredns-*`
- `aws-node-*` (VPC CNI)
- `kube-proxy-*`
- `ebs-csi-controller-*` (if enabled)
- `eks-pod-identity-*` (managed IRSA, if enabled)

---

# Notes

- This module assumes the network layer is already created.  
- This module is **safe to destroy and recreate** for dev/stage use.  
- System components (CoreDNS, kube-proxy, CNI) are managed via EKS Addons.  
- IRSA is the recommended way to give pods AWS permissions — never use node IAM for pods.

---

# Summary

This module provides a **secure, production-ready, cost-conscious** AWS EKS cluster with:
- IAM roles  
- Security groups  
- Node groups  
- Addons  
- IRSA  
- Optional encryption  
- Autoscaler support

