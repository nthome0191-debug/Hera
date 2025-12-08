locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "kind_cluster" {
  source = "../../modules/kubernetes-cluster/local-kind"

  cluster_name    = var.cluster_name
  worker_groups = var.worker_groups
  kubeconfig_path = var.kubeconfig_path
  tags            = local.tags
}
