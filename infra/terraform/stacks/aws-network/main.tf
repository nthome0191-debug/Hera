
module "network" {
  source   = "../../modules/network/aws"
  region   = var.region
  vpc_name = "${var.environment}-vpc"
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
  clusters = var.clusters
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
}

# module "eks_clusters" {
#   for_each = { for c in var.clusters : c.name => c }
#   source   = "../../modules/eks/aws" # Assuming you'll build this next
  
#   cluster_name = each.value.name
#   vpc_id       = module.network.vpc_id
#   # Dynamically pick the subnets created by the network module for THIS cluster
#   subnet_ids   = [for az in each.value.azs : module.network.private_subnets["${each.value.name}-${az}"]]
# }