module "aws_cluster" {
  source = "../../../../stacks/aws-cluster"

  # Global
  region         = var.region
  aws_account_id = var.aws_account_id
  project        = var.project
  environment    = var.environment

  # Network
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  private_subnet_cidrs     = var.private_subnet_cidrs
  public_subnet_cidrs      = var.public_subnet_cidrs
  enable_nat_gateway       = var.enable_nat_gateway
  single_nat_gateway       = var.single_nat_gateway
  enable_vpc_endpoints     = var.enable_vpc_endpoints
  vpc_endpoints            = var.vpc_endpoints
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days
  flow_logs_traffic_type   = var.flow_logs_traffic_type

  # EKS
  cluster_name               = var.cluster_name
  kubernetes_version         = var.kubernetes_version
  kubeconfig_context_name    = var.kubeconfig_context_name
  node_groups                = var.node_groups
  enable_private_endpoint    = var.enable_private_endpoint
  enable_public_endpoint     = var.enable_public_endpoint
  authorized_networks        = var.authorized_networks
  enable_cluster_autoscaler  = var.enable_cluster_autoscaler
  cluster_log_retention_days = var.cluster_log_retention_days
  enable_irsa                = var.enable_irsa
  use_random_suffix          = var.use_random_suffix
  eks_addons                 = var.eks_addons

  # CloudTrail
  create_cloudtrail = var.create_cloudtrail
  cloudtrail_name   = var.cloudtrail_name

  # Access management
  users                  = var.users
  enforce_password_policy = var.enforce_password_policy
  enforce_mfa             = var.enforce_mfa
  allowed_ip_ranges       = var.allowed_ip_ranges
}
