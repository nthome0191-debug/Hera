module "network" {
  source = "../../../../stacks/aws-network"

  # Global
  region      = var.region
  project     = var.project
  environment = var.environment

  # VPC
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  # Subnets
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  # NAT Gateway
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # VPC Endpoints
  enable_vpc_endpoints = var.enable_vpc_endpoints
  vpc_endpoints        = var.vpc_endpoints

  # Multi-cluster support
  cluster_names = var.cluster_names

  # VPC Flow Logs
  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days
  flow_logs_traffic_type   = var.flow_logs_traffic_type
}
