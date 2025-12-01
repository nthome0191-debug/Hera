# Development Environment - AWS
# This file orchestrates network, cluster, and platform modules
# Contains only composition logic, no business logic
#
# IMPORTANT: This environment uses remote state backed by S3.
# The S3 bucket and DynamoDB table must be created FIRST by applying
# the bootstrap environment (envs/bootstrap/aws/)

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "network" {
  source = "../../../modules/network/aws"

  region                    = var.region
  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  private_subnet_cidrs      = var.private_subnet_cidrs
  public_subnet_cidrs       = var.public_subnet_cidrs
  enable_nat_gateway        = var.enable_nat_gateway
  single_nat_gateway        = var.single_nat_gateway
  enable_vpc_endpoints      = var.enable_vpc_endpoints
  vpc_endpoints             = var.vpc_endpoints
  cluster_name              = var.cluster_name
  enable_flow_logs          = var.enable_flow_logs
  flow_logs_retention_days  = var.flow_logs_retention_days
  flow_logs_traffic_type    = var.flow_logs_traffic_type
  tags                      = local.tags
}
#
# module "eks_cluster" {
#   source = "../../../modules/kubernetes-cluster/aws-eks"
#
#   cluster_name             = var.cluster_name
#   environment              = var.environment
#   region                   = var.region
#   kubernetes_version       = var.kubernetes_version
#   vpc_id                   = module.network.vpc_id
#   private_subnet_ids       = module.network.private_subnet_ids
#   public_subnet_ids        = module.network.public_subnet_ids
#   node_groups              = var.node_groups
#   enable_private_endpoint  = var.enable_private_endpoint
#   enable_public_endpoint   = var.enable_public_endpoint
#   authorized_networks      = var.authorized_networks
#   tags                     = var.tags
# }
#
# module "platform_base" {
#   source = "../../../modules/platform/base"
#
#   cluster_name           = var.cluster_name
#   cluster_endpoint       = module.eks_cluster.cluster_endpoint
#   cluster_ca_certificate = module.eks_cluster.cluster_ca_certificate
#   kubeconfig             = module.eks_cluster.kubeconfig
#   cloud_provider         = "aws"
#   environment            = var.environment
# }
