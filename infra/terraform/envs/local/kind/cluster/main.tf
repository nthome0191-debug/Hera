module "local_cluster" {
  source = "../../../../stacks/local-cluster"

  project         = var.project
  environment     = var.environment
  cluster_name    = var.cluster_name
  worker_groups = var.worker_groups
  kubeconfig_path = var.kubeconfig_path
}
