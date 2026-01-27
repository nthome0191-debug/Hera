
locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ClusterType = var.cluster_type
    ManagedBy   = "Terraform"
    Stack       = "aws-eks-only"
  }
}

module "eks_cluster" {
  source = "../../modules/kubernetes-cluster/aws-eks"

  region      = var.region
  environment = var.environment

  cluster_name            = var.cluster_name
  cluster_type            = var.cluster_type
  deployment_mode         = var.deployment_mode
  primary_az              = var.primary_az
  kubernetes_version      = var.kubernetes_version
  kubeconfig_context_name = var.kubeconfig_context_name

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  node_groups = var.node_groups


  enable_private_endpoint = var.enable_private_endpoint
  enable_public_endpoint  = var.enable_public_endpoint
  authorized_networks     = var.authorized_networks

  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_log_retention_days = var.cluster_log_retention_days
  enable_irsa                = var.enable_irsa
  use_random_suffix          = var.use_random_suffix
  eks_addons                 = var.eks_addons

  # Cluster encryption (optional, for PCI clusters)
  enable_cluster_encryption     = var.enable_cluster_encryption
  cluster_encryption_kms_key_id = var.cluster_encryption_kms_key_id

  # Cross-cluster communication
  peer_cluster_security_group_ids = var.peer_cluster_security_group_ids

  tags = local.tags
}

module "karpenter" {
  source = "../../modules/karpenter"

  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  oidc_provider_arn                  = module.eks.oidc_provider_arn
  
  karpenter_version                  = var.karpenter_version

  # Ensure the cluster exists before installing Karpenter
  depends_on = [module.eks]
}
