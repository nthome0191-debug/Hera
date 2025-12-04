terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Random suffix to avoid naming conflicts during destroy/recreate cycles
resource "random_string" "suffix" {
  count   = var.use_random_suffix ? 1 : 0
  length  = 6
  special = false
  upper   = false
}

locals {
  cluster_name_with_suffix = var.use_random_suffix ? "${var.cluster_name}-${random_string.suffix[0].result}" : var.cluster_name
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${local.cluster_name_with_suffix}/cluster"
  retention_in_days = var.cluster_log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-eks-logs"
    }
  )
}

resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name_with_suffix}-eks-cluster-role"

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
      Name = "${local.cluster_name_with_suffix}-eks-cluster-role"
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

resource "aws_security_group" "cluster" {
  name_prefix = "${local.cluster_name_with_suffix}-eks-cluster-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-eks-cluster-sg"
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

resource "aws_eks_cluster" "main" {
  name     = local.cluster_name_with_suffix
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
      Name = local.cluster_name_with_suffix
    }
  )
}

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
      Name = "${local.cluster_name_with_suffix}-irsa"
    }
  )
}
resource "aws_iam_role" "node" {
  name = "${local.cluster_name_with_suffix}-eks-node-role"

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
      Name = "${local.cluster_name_with_suffix}-eks-node-role"
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

resource "aws_security_group" "node" {
  name_prefix = "${local.cluster_name_with_suffix}-eks-node-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                                       = "${local.cluster_name_with_suffix}-eks-node-sg"
      "kubernetes.io/cluster/${local.cluster_name_with_suffix}" = "owned"
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

resource "aws_launch_template" "node" {
  for_each = var.node_groups

  name_prefix = "${local.cluster_name_with_suffix}-${each.key}-"
  description = "Launch template for ${local.cluster_name_with_suffix} EKS node group ${each.key}"

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
        Name = "${local.cluster_name_with_suffix}-${each.key}-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${local.cluster_name_with_suffix}-${each.key}-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-${each.key}-launch-template"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.cluster_name_with_suffix}-${each.key}"
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
      Name = "${local.cluster_name_with_suffix}-${each.key}-node-group"
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
locals {
  # Build addons map from the eks_addons variable based on enabled flag
  enabled_addons = {
    for addon_key, addon_config in {
      "vpc-cni" = var.eks_addons.vpc_cni.enabled ? {
        version           = var.eks_addons.vpc_cni.version
        resolve_conflicts = var.eks_addons.vpc_cni.resolve_conflicts
        service_account_role_arn = var.eks_addons.vpc_cni.service_account_role_arn != "" ? var.eks_addons.vpc_cni.service_account_role_arn : null
      } : null
      "kube-proxy" = var.eks_addons.kube_proxy.enabled ? {
        version           = var.eks_addons.kube_proxy.version
        resolve_conflicts = var.eks_addons.kube_proxy.resolve_conflicts
        service_account_role_arn = var.eks_addons.kube_proxy.service_account_role_arn != "" ? var.eks_addons.kube_proxy.service_account_role_arn : null
      } : null
      "coredns" = var.eks_addons.coredns.enabled ? {
        version           = var.eks_addons.coredns.version
        resolve_conflicts = var.eks_addons.coredns.resolve_conflicts
        service_account_role_arn = var.eks_addons.coredns.service_account_role_arn != "" ? var.eks_addons.coredns.service_account_role_arn : null
      } : null
      "aws-ebs-csi-driver" = var.eks_addons.aws_ebs_csi_driver.enabled ? {
        version           = var.eks_addons.aws_ebs_csi_driver.version
        resolve_conflicts = var.eks_addons.aws_ebs_csi_driver.resolve_conflicts
        service_account_role_arn = var.eks_addons.aws_ebs_csi_driver.service_account_role_arn != "" ? var.eks_addons.aws_ebs_csi_driver.service_account_role_arn : (var.enable_irsa && var.eks_addons.aws_ebs_csi_driver.enabled ? aws_iam_role.ebs_csi[0].arn : null)
      } : null
    } : addon_key => addon_config
    if addon_config != null
  }
}

resource "aws_eks_addon" "addons" {
  for_each = local.enabled_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_create = each.value.resolve_conflicts
  resolve_conflicts_on_update = each.value.resolve_conflicts
  service_account_role_arn    = each.value.service_account_role_arn

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-${each.key}"
    }
  )
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  count = var.eks_addons.aws_ebs_csi_driver.enabled && var.enable_irsa ? 1 : 0

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
  count = var.eks_addons.aws_ebs_csi_driver.enabled && var.enable_irsa ? 1 : 0

  name               = "${local.cluster_name_with_suffix}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-ebs-csi-driver"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count = var.eks_addons.aws_ebs_csi_driver.enabled && var.enable_irsa ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi[0].name
}

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

  name               = "${local.cluster_name_with_suffix}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role[0].json

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-cluster-autoscaler"
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
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${local.cluster_name_with_suffix}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name        = "${local.cluster_name_with_suffix}-cluster-autoscaler"
  description = "IAM policy for Cluster Autoscaler"
  policy      = data.aws_iam_policy_document.cluster_autoscaler[0].json

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name_with_suffix}-cluster-autoscaler"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler && var.enable_irsa ? 1 : 0

  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
  role       = aws_iam_role.cluster_autoscaler[0].name
}

data "aws_caller_identity" "current" {}

resource "null_resource" "update_kubeconfig" {
  depends_on = [aws_eks_cluster.main]

  triggers = {
    cluster_name = aws_eks_cluster.main.name
    region       = var.region
    context_name = var.kubeconfig_context_name
  }

  provisioner "local-exec" {
    command = <<EOT
aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}

if [ "${var.kubeconfig_context_name}" != "" ]; then
  kubectl config rename-context arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${aws_eks_cluster.main.name} ${var.kubeconfig_context_name} || true
fi
EOT
  }
}

