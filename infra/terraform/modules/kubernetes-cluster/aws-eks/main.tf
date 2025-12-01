# CloudWatch Log Group for EKS Control Plane Logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-logs"
    }
  )
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# EKS Cluster Security Group
resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}-eks-cluster-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-cluster-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all outbound traffic"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = var.enable_private_endpoint
    endpoint_public_access  = var.enable_public_endpoint
    public_access_cidrs     = var.enable_public_endpoint ? var.authorized_networks : []
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = var.cluster_log_types

  dynamic "encryption_config" {
    for_each = var.enable_cluster_encryption ? [1] : []
    content {
      provider {
        key_arn = var.cluster_encryption_kms_key_id
      }
      resources = ["secrets"]
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.eks_cluster,
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}

# OIDC Provider for IRSA
data "tls_certificate" "cluster" {
  count = var.enable_irsa ? 1 : 0
  url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count = var.enable_irsa ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-irsa"
    }
  )
}

# Node Group IAM Role
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node.name
}

# Node Security Group
resource "aws_security_group" "node" {
  name_prefix = "${var.cluster_name}-eks-node-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-eks-node-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.node.id
  description       = "Allow nodes to communicate with each other"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node.id
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
}

resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "cluster_ingress_node_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.cluster.id
  description              = "Allow pods to communicate with the cluster API Server"
}

# Launch Template for Node Groups
resource "aws_launch_template" "node" {
  for_each = var.node_groups

  name_prefix = "${var.cluster_name}-${each.key}-"
  description = "Launch template for ${var.cluster_name} EKS node group ${each.key}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-${each.key}-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-${each.key}-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Node Groups
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = "$Latest"
  }

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  labels = merge(
    each.value.labels,
    {
      "node-group" = each.key
    }
  )

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}-node-group"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}

# EKS Addons
locals {
  default_addons = var.enable_addons ? {
    vpc-cni = {
      version                  = "v1.18.1-eksbuild.3"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    kube-proxy = {
      version                  = "v1.31.0-eksbuild.5"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    coredns = {
      version                  = "v1.11.3-eksbuild.2"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
  } : {}

  ebs_csi_addon = var.enable_ebs_csi_driver ? {
    aws-ebs-csi-driver = {
      version                  = "v1.37.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = var.enable_irsa ? aws_iam_role.ebs_csi[0].arn : ""
    }
  } : {}

  all_addons = merge(local.default_addons, local.ebs_csi_addon, var.addons)
}

resource "aws_eks_addon" "addons" {
  for_each = local.all_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = each.value.resolve_conflicts
  resolve_conflicts_on_update = each.value.resolve_conflicts
  service_account_role_arn    = each.value.service_account_role_arn != "" ? each.value.service_account_role_arn : null

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${each.key}"
    }
  )
}

# IAM Role for EBS CSI Driver
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  count = var.enable_ebs_csi_driver && var.enable_irsa ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster[0].arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster[0].url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  count = var.enable_ebs_csi_driver && var.enable_irsa ? 1 : 0

  name               = "${var.cluster_name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-ebs-csi-driver"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count = var.enable_ebs_csi_driver && var.enable_irsa ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi[0].name
}

# IAM Policy for Cluster Autoscaler
data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {
  count = var.enable_cluster_autoscaler && var.enable_irsa ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster[0].arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster[0].url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler && var.enable_irsa ? 1 : 0

  name               = "${var.cluster_name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-autoscaler"
    }
  )
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name        = "${var.cluster_name}-cluster-autoscaler"
  description = "IAM policy for Cluster Autoscaler"
  policy      = data.aws_iam_policy_document.cluster_autoscaler[0].json

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-autoscaler"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler && var.enable_irsa ? 1 : 0

  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
  role       = aws_iam_role.cluster_autoscaler[0].name
}
