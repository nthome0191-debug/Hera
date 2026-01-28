resource "aws_security_group" "cluster" {
  name_prefix = "${local.name_prefix}-cluster-sg-"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id
  tags        = local.common_tags
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group" "node" {
  name_prefix = "${local.name_prefix}-node-sg-"
  description = "EKS worker nodes security group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    "kubernetes.io/cluster/${local.name_prefix}" = "owned"
  })
}

resource "aws_security_group_rule" "node_internal" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_from_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node.id
}