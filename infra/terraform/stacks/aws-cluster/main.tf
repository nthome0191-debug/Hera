locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "network" {
  source = "../../modules/network/aws"

  region                   = var.region
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  private_subnet_cidrs     = var.private_subnet_cidrs
  public_subnet_cidrs      = var.public_subnet_cidrs
  enable_nat_gateway       = var.enable_nat_gateway
  single_nat_gateway       = var.single_nat_gateway
  enable_vpc_endpoints     = var.enable_vpc_endpoints
  vpc_endpoints            = var.vpc_endpoints
  cluster_name             = var.cluster_name
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days
  flow_logs_traffic_type   = var.flow_logs_traffic_type
  tags                     = local.tags
}

module "eks_cluster" {
  source = "../../modules/kubernetes-cluster/aws-eks"

  cluster_name               = var.cluster_name
  environment                = var.environment
  region                     = var.region
  kubernetes_version         = var.kubernetes_version
  kubeconfig_context_name    = var.kubeconfig_context_name
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  public_subnet_ids          = module.network.public_subnet_ids
  node_groups                = var.node_groups
  enable_private_endpoint    = var.enable_private_endpoint
  enable_public_endpoint     = var.enable_public_endpoint
  authorized_networks        = var.authorized_networks
  enable_cluster_autoscaler  = var.enable_cluster_autoscaler
  cluster_log_retention_days = var.cluster_log_retention_days
  enable_irsa                = var.enable_irsa
  use_random_suffix          = var.use_random_suffix
  eks_addons                 = var.eks_addons
  tags                       = local.tags

  depends_on = [
    module.network
  ]
}

module "cloudtrail" {
  source = "../../modules/cloud-activity/aws/cloudtrail"

  region = var.region
  create_cloudtrail = var.create_cloudtrail
  cloudtrail_name   = var.cloudtrail_name
  project           = var.project
  tags              = var.tags
}

module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name      = module.aws_eks_cluster.cluster_name
  cluster_endpoint  = module.aws_eks_cluster.cluster_endpoint
  oidc_provider_arn = module.aws_eks_cluster.oidc_provider_arn
  
  cluster_certificate_authority_data = module.aws_eks_cluster.cluster_ca_certificate

  depends_on = [module.aws_eks_cluster]
}