resource "aws_launch_template" "node" {
  for_each = var.node_groups

  name_prefix = "${local.name_prefix}-${each.key}-"
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value.disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}-node" })
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = local.node_subnet_ids 

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = "$Latest"
  }

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}