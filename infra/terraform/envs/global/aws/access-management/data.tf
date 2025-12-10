# Data sources for EKS cluster (only when cluster is configured)
data "aws_eks_cluster" "cluster" {
  count = var.cluster_name != "" ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.cluster_name != "" ? 1 : 0
  name  = var.cluster_name
}
