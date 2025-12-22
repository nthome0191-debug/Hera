module "eks_cluster" {
  source = "../../../../stacks/aws-eks-only"

  # Global
  region      = var.region
  environment = var.environment
  project     = var.project

  # Cluster configuration
  cluster_name        = var.cluster_name
  cluster_type        = var.cluster_type
  deployment_mode     = var.deployment_mode
  primary_az          = var.primary_az
  kubernetes_version  = var.kubernetes_version

  # Network (from remote state)
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.dev_infra_private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.network.outputs.public_subnet_ids

  # Node groups
  node_groups = var.node_groups

  # Add-ons
  eks_addons = var.eks_addons

  # IRSA
  enable_irsa = var.enable_irsa

  # Logging
  cluster_log_retention_days = var.cluster_log_retention_days

  # Cross-cluster communication (will be updated in Phase 6)
  peer_cluster_security_group_ids = []
}
