# Development Environment - AWS
# This file orchestrates network, cluster, and platform modules
# Contains only composition logic, no business logic

# TODO: Implement module composition
#
# module "network" {
#   source = "../../../modules/network/aws"
#
#   environment           = var.environment
#   region               = var.region
#   vpc_cidr             = var.vpc_cidr
#   availability_zones   = var.availability_zones
#   private_subnet_cidrs = var.private_subnet_cidrs
#   public_subnet_cidrs  = var.public_subnet_cidrs
#   enable_nat_gateway   = var.enable_nat_gateway
#   tags                 = var.tags
# }
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

terraform {
  backend "s3" {}
}

locals {
  project     = var.project
  environment = var.environment

  bucket_name     = "${local.project}-${local.environment}-tf-state"
  lock_table_name = "${local.project}-${local.environment}-tf-lock"
  admin_role_name = "${local.project}-${local.environment}-admin"
}

module "bootstrap" {
  source = "../../../modules/bootstrap/aws"

  region  = var.region

  bucket_name         = local.bucket_name
  bucket_force_destroy = false
  bucket_versioning    = "Enabled"
  bucket_sse_algo      = "AES256"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lock_table_name          = local.lock_table_name
  lock_table_hash_key       = "LockID"
  lock_table_hash_key_type  = "S"
  lock_table_billing_mode   = "PAY_PER_REQUEST"

  create_admin_role   = true
  admin_role_name     = local.admin_role_name
  admin_principal_arn = "arn:aws:iam::${var.aws_account_id}:root"
  admin_policy_arn    = "arn:aws:iam::aws:policy/AdministratorAccess"

  tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
