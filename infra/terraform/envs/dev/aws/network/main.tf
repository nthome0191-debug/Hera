module "network" {
  source = "../../../../stacks/aws-network"

  environment = var.environment
  region = var.region
  vpc_cidr = var.vpc_cidr
  azs = var.azs
  clusters = var.clusters
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

}
