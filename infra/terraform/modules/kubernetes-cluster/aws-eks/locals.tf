locals {
  name_prefix = var.use_random_suffix ? "${var.cluster_name}-${random_string.suffix[0].result}" : var.cluster_name
  
  common_tags = merge(
    var.tags,
    {
      "hera.io/project" = "Hera"
      "hera.io/env"     = var.environment
      "hera.io/managed-by" = "terraform"
    }
  )

  node_subnet_ids = var.deployment_mode == "single-az" && var.primary_az != "" ? [
    for s in data.aws_subnet.private : s.id if s.availability_zone == var.primary_az
  ] : var.private_subnet_ids
}