# module "aws_cluster" {
#   source = "../../../../stacks/aws-cluster"

#   # Global
#   region         = var.region
#   aws_account_id = var.aws_account_id
#   project        = var.project
#   environment    = var.environment

#   # EKS
#   cluster_name               = var.cluster_name
#   kubernetes_version         = var.kubernetes_version
#   kubeconfig_context_name    = var.kubeconfig_context_name
#   node_groups                = var.node_groups
#   enable_private_endpoint    = var.enable_private_endpoint
#   enable_public_endpoint     = var.enable_public_endpoint
#   authorized_networks        = var.authorized_networks
#   enable_cluster_autoscaler  = var.enable_cluster_autoscaler
#   cluster_log_retention_days = var.cluster_log_retention_days
#   enable_irsa                = var.enable_irsa
#   use_random_suffix          = var.use_random_suffix
#   eks_addons                 = var.eks_addons

#   # CloudTrail
#   create_cloudtrail = var.create_cloudtrail
#   cloudtrail_name   = var.aws_account_id
# }
