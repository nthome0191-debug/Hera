module "local_cluster" {
  source = "../../../stacks/local-cluster"

  project         = var.project
  environment     = var.environment
  cluster_name    = var.cluster_name
  worker_nodes    = var.worker_nodes
  kubeconfig_path = var.kubeconfig_path
}
