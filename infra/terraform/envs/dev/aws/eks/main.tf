locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "eks_cluster" {
  source = "../../../modules/kubernetes-cluster/aws-eks"

  cluster_name                = var.cluster_name
  environment                 = var.environment
  region                      = var.region
  kubernetes_version          = var.kubernetes_version
  vpc_id                      = module.network.vpc_id
  private_subnet_ids          = module.network.private_subnet_ids
  public_subnet_ids           = module.network.public_subnet_ids
  node_groups                 = var.node_groups
  enable_private_endpoint     = var.enable_private_endpoint
  enable_public_endpoint      = var.enable_public_endpoint
  authorized_networks         = var.authorized_networks
  enable_cluster_autoscaler   = var.enable_cluster_autoscaler
  cluster_log_retention_days  = var.cluster_log_retention_days
  enable_irsa                 = var.enable_irsa
  use_random_suffix           = var.use_random_suffix
  eks_addons                  = var.eks_addons
  tags                        = local.tags
}