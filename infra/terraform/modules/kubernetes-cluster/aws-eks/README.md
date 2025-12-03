# Hera - AWS EKS Cluster Module

This module provisions a **production-ready Amazon EKS cluster** for Hera on top of the AWS network module.

It is designed to be:

- **Managed** - uses Amazon EKS for the control plane
- **Secure** - IRSA, encrypted volumes, SG separation, private endpoint support
- **Flexible** - multiple node groups, taints, labels, capacity types
- **Cost-aware** - dev and prod modes via configuration

This module is **optionally ephemeral**: you can destroy and recreate clusters (for dev/staging) while keeping the bootstrap + network layers intact.

---

## What This Module Creates

### 1. CloudWatch Log Group for Control Plane

**Resource:** `aws_cloudwatch_log_group.eks_cluster`  
**Function:** Stores EKS control plane logs:
- `api`, `audit`, `authenticator`, `controllerManager`, `scheduler` (configurable via `cluster_log_types`)  
**Config:**  
- `cluster_log_retention_days` - retention in days (default: 7)

**Cost (approx):**
- Ingestion + storage, typically **$1-$10/month** depending on traffic and retention.

**Dev recommendation:**
- Keep enabled but with **short retention** (7 days).  
**Prod recommendation:**
- Keep enabled with **7-30 days retention**, especially `api` and `audit`.

---

### 2. EKS Cluster IAM Role

**Resources:**
- `aws_iam_role.cluster`
- Attachments:
  - `AmazonEKSClusterPolicy`
  - `AmazonEKSVPCResourceController`

**Function:**  
Permissions for the EKS control plane to manage cluster resources in your VPC.

**Cost:**  
- IAM roles and policies are free.

---

### 3. Cluster Security Group

**Resources:**
- `aws_security_group.cluster`
- `aws_security_group_rule.cluster_egress`
- `aws_security_group_rule.cluster_ingress_node_https`

**Function:**
- Isolates the control plane.
- Allows:
  - All outbound
  - HTTPS from nodes to API server
  - API server to talk to nodes

**Config:**
- `vpc_id` - VPC where the SG is created.

---

### 4. EKS Cluster (Control Plane)

**Resource:** `aws_eks_cluster.main`

**Function:**  
Creates the managed Kubernetes control plane.

**Config:**

- `cluster_name` - name of the cluster
- `environment` - environment (dev/staging/prod)
- `region` - AWS region
- `kubernetes_version` - default: `1.32`
- `vpc_id` - underlying VPC
- `private_subnet_ids` - used for worker nodes
- `public_subnet_ids` - optional, used mainly for public Load Balancers
- `enable_private_endpoint` - enable private API endpoint (default: `true`)
- `enable_public_endpoint` - enable public API endpoint (default: `true`)
- `authorized_networks` - CIDR blocks allowed to reach public endpoint
- `cluster_log_types` - enabled control-plane log types
- `enable_cluster_encryption` - enable secrets encryption using KMS
- `cluster_encryption_kms_key_id` - KMS key used when encryption is enabled

**Cost (approx):**
- EKS control plane: ~**$0.10/hour** → **~$72/month** per cluster.

**Dev recommendation:**
- Can keep a single dev EKS cluster up or destroy nightly.
- If using public endpoint: restrict `authorized_networks` to your IP/CIDR.
- Consider leaving private endpoint on, public off in secure setups.

**Prod recommendation:**
- **Private endpoint:** `true`
- **Public endpoint:** `false` or limited to known admin/CIDR ranges.
- Always enable control plane logs.
- Strongly consider KMS encryption in regulated environments.

---

### 5. OIDC Provider for IRSA

**Resources:**
- `data.tls_certificate.cluster`
- `aws_iam_openid_connect_provider.cluster` (conditional)

**Function:**  
Enables **IAM Roles for Service Accounts (IRSA)** so pods can assume fine-grained IAM roles instead of using node IAM.

**Config:**
- `enable_irsa` - default: `true`

**Cost:**  
- OIDC provider is free.

**Recommendation:**  
- **Dev:** Keep enabled.  
- **Prod:** Always enabled. Required for secure IAM for addons like EBS CSI, Cluster Autoscaler, external-dns, etc.

---

### 6. Node Group IAM Role & Security Group

**Resources:**
- `aws_iam_role.node`
- Attachments:
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`
  - `AmazonEC2ContainerRegistryReadOnly`
  - `AmazonSSMManagedInstanceCore`
- `aws_security_group.node` and its rules:
  - `node_ingress_self`
  - `node_ingress_cluster`
  - `node_egress`

**Function:**
- IAM role for EC2 worker nodes.
- Security group for node-to-node and node-to-control-plane communication.

**Cost:**  
- IAM + SG themselves are free.

---

### 7. Node Launch Templates

**Resource:** `aws_launch_template.node` (one per node group)

**Function:**
Defines:
- Root volume size/type (`disk_size`, `gp3`, encrypted)
- Metadata options (IMDSv2 required)
- Monitoring
- Tags for instances & volumes

**Config via `node_groups` map:**
- `disk_size` - per node group
- Any instance-level tuning is driven by EKS node group configuration.

---

### 8. EKS Node Groups

**Resource:** `aws_eks_node_group.main` (for each `node_groups` entry)

**Function:**  
Creates managed node groups for the cluster.

**Config (per node group in `node_groups`):**
- `desired_size`, `min_size`, `max_size`
- `instance_types` - list of EC2 types
- `capacity_type` - `ON_DEMAND` or `SPOT`
- `disk_size`
- `labels` - node labels
- `taints` - scheduling taints (key/value/effect)

**Cost (approx):**
- Driven mainly by **EC2 instance type** and hours:
  - Example: 3 × `t3.medium` → ~**$90-$100/month**
  - Example: 3 × `m5.large` → ~**$200+/month**
- SPOT capacity can reduce compute cost by **50-70%**, but with eviction risk.

**Dev recommendation:**
- 1 small node group:
  - `desired_size = 1-2`
  - `instance_types = ["t3.medium"]` or similar
  - `capacity_type = "SPOT"` where acceptable
- Minimal taints; dedicated tainted pools only if testing.

**Prod recommendation:**
- At least **2-3 node groups**:
  - On-demand group for critical workloads
  - Spot group(s) for cost-efficient workloads
  - Distinct labels/taints for separating system, apps, and batch workloads.
- Use multiple instance types for Spot resilience.

---

### 9. EKS Addons

**Local Computed Addons:**
- `vpc-cni`
- `kube-proxy`
- `coredns`

Plus:
- Optional `aws-ebs-csi-driver` when `enable_ebs_csi_driver = true`
- User-specified addons via `addons` variable

**Resource:** `aws_eks_addon.addons`

**Function:**  
Managed EKS addons with pinned versions and conflict resolution.

**Config:**
- `enable_addons` - enable default core addons
- `enable_ebs_csi_driver` - EBS CSI driver (default: `true`)
- `addons` - custom addons map:
  - `version`
  - `resolve_conflicts`
  - `service_account_role_arn`

**Cost:**
- Addons themselves usually cost nothing extra; they run on cluster resources (nodes).

**Recommendation:**
- Dev: keep default addons, optional EBS CSI.  
- Prod: enable EBS CSI driver, plus any storage/networking addons you require (with IRSA roles where needed).

---

### 10. IRSA Roles: EBS CSI Driver

**Resources:**
- `data.aws_iam_policy_document.ebs_csi_assume_role`
- `aws_iam_role.ebs_csi`
- `aws_iam_role_policy_attachment.ebs_csi`

**Function:**  
Dedicated IAM role for the EBS CSI controller via IRSA.

**Config:**
- `enable_ebs_csi_driver` (default: `true`)
- `enable_irsa` must be `true`

**Recommendation:**
- Dev: enabled (default) for realistic storage behavior.
- Prod: always enabled if you use EBS volumes.

---

### 11. IRSA Roles: Cluster Autoscaler

**Resources:**
- `data.aws_iam_policy_document.cluster_autoscaler_assume_role`
- `aws_iam_role.cluster_autoscaler`
- `data.aws_iam_policy_document.cluster_autoscaler`
- `aws_iam_policy.cluster_autoscaler`
- `aws_iam_role_policy_attachment.cluster_autoscaler`

**Function:**  
IAM role and policy for Kubernetes Cluster Autoscaler to scale node groups.

**Config:**
- `enable_cluster_autoscaler` (default: `false`)
- `enable_irsa` must be `true` to use IRSA role.

**Recommendation:**
- Dev: optional, can be useful for dynamic testing.
- Prod: strongly recommended for efficient scaling and cost optimization.

---

## Inputs Overview

Key inputs (see `variables.tf` for full definition):

- `cluster_name` (string, required)
- `environment` (string, required)
- `region` (string, required)
- `kubernetes_version` (string, default `"1.32"`)
- `vpc_id` (string, required)
- `private_subnet_ids` (list(string), required)
- `public_subnet_ids` (list(string), default `[]`)
- `enable_private_endpoint` (bool, default `true`)
- `enable_public_endpoint` (bool, default `true`)
- `authorized_networks` (list(string), default `["0.0.0.0/0"]`)
- `enable_irsa` (bool, default `true`)
- `cluster_log_types` (list(string), default control-plane logs)
- `cluster_log_retention_days` (number, default `7`)
- `node_groups` (map(object), default `{}`)
- `enable_cluster_encryption` (bool, default `false`)
- `cluster_encryption_kms_key_id` (string, default `""`)
- `enable_addons` (bool, default `true`)
- `addons` (map(object), default `{}`)
- `enable_cluster_autoscaler` (bool, default `false`)
- `enable_ebs_csi_driver` (bool, default `true`)
- `enable_efs_csi_driver` (bool, default `false`)
- `tags` (map(string), default `{}`)

---

## Dev vs Prod Recommended Profiles

### Dev / Early Stage

- 1 small node group (`SPOT`, 1-2 nodes)
- `enable_public_endpoint = true` but restricted `authorized_networks` (your office/home CIDR)
- `enable_private_endpoint = true`
- `cluster_log_retention_days = 7`
- `enable_cluster_encryption = false` (unless you need strict compliance)
- `enable_cluster_autoscaler = false` or minimal
- Destroy cluster nightly if you want to save more

### Production

- Multi-AZ private subnets for nodes
- `enable_private_endpoint = true`
- `enable_public_endpoint = false` or very restricted
- **Multiple node groups:**
  - On-demand for system + critical apps
  - Spot for non-critical workloads
- `enable_cluster_autoscaler = true`
- `enable_cluster_encryption = true` with managed KMS key
- `cluster_log_retention_days = 14-30`
- IRSA enabled and used for all system components/addons

---

## Approximate Monthly Cost (One Small Cluster)

Highly dependent on node config; example for a **small dev cluster**:

- EKS control plane: ~**$72/month**
- 2 × `t3.medium` nodes (on-demand): ~**$60-$80/month**
- CloudWatch logs (7 days, low traffic): ~**$1-$5/month**

**Total dev ballpark:** ~**$130-$160/month**

For production with more nodes and multiple node groups, expect **hundreds of USD/month**, dominated by EC2 nodes rather than EKS control plane itself.

---

## Notes

- This module assumes the **network module** (VPC, subnets, endpoints, NAT) is already applied.
- This module should be safe to **destroy and recreate** without affecting the bootstrap and network layers.
- Always plan node group sizes and instance types according to real workload and SLOs.
