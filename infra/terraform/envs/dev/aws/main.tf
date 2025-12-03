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

module "eks_cluster" {
  source = "../../../modules/kubernetes-cluster/aws-eks"

  cluster_name                = var.cluster_name
  environment                 = var.environment
  region                      = var.region
  kubernetes_version          = var.kubernetes_version
  vpc_id                      = module.network.vpc_id
  private_subnet_ids          = module.network.private_subnet_ids
  public_subnet_ids           = module.network.public_subnet_ids
  node_groups                 = var.node_groups
  enable_private_endpoint     = var.enable_private_endpoint
  enable_public_endpoint      = var.enable_public_endpoint
  authorized_networks         = var.authorized_networks
  enable_cluster_autoscaler   = var.enable_cluster_autoscaler
  cluster_log_retention_days  = var.cluster_log_retention_days
  enable_irsa                 = var.enable_irsa
  use_random_suffix           = var.use_random_suffix
  eks_addons                  = var.eks_addons
  tags                        = local.tags
}

# ============================================
# Platform Layer: Gitea + ArgoCD
# ============================================
# Gitea provides in-cluster Git for dev (fast iteration, no external deps)
# ArgoCD provides GitOps continuous delivery
# Each service deployed to its own namespace for isolation

module "gitea" {
  source = "../../../modules/platform/gitea"

  cluster_name     = var.cluster_name
  namespace        = "git"  # Separate namespace for Gitea
  create_namespace = true
  admin_username   = "gitea-admin"
  admin_email      = "admin@dev.local"
  tags             = local.tags

  depends_on = [module.eks_cluster]
}

module "argocd" {
  source = "../../../modules/platform/argocd"

  cluster_name     = var.cluster_name
  namespace        = "argocd"  # Separate namespace for ArgoCD
  create_namespace = true

  # Connect ArgoCD to in-cluster Gitea (after you create a repo in Gitea)
  # Note: Uncomment these lines AFTER:
  # 1. Deploying the infrastructure (terraform apply)
  # 2. Creating a repository "gitops-repo" in Gitea UI
  # 3. Running terraform apply again to create the connection
  #
  # git_repository_url      = "${module.gitea.service_url}/gitea-admin/gitops-repo"
  # git_repository_username = module.gitea.admin_username
  # git_repository_password = module.gitea.admin_password

  # ArgoCD configuration (dev-optimized, minimal resources)
  values = yamlencode({
    server = {
      replicas = 1
      resources = {
        requests = { cpu = "100m", memory = "128Mi" }
        limits   = { cpu = "200m", memory = "256Mi" }
      }
    }
    repoServer = {
      replicas = 1
      resources = {
        requests = { cpu = "100m", memory = "256Mi" }
        limits   = { cpu = "200m", memory = "512Mi" }
      }
    }
    controller = {
      replicas = 1
      resources = {
        requests = { cpu = "250m", memory = "512Mi" }
        limits   = { cpu = "500m", memory = "1Gi" }
      }
    }
  })

  tags = local.tags

  depends_on = [module.gitea]
}
