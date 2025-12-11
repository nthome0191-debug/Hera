data "aws_eks_cluster" "cluster" {
  name = module.aws_cluster.cluster_name

  depends_on = [
    module.aws_cluster
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_cluster.cluster_name

  depends_on = [
    module.aws_cluster
  ]
}
