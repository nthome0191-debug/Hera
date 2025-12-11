module "aws_cluster_access" {
  source = "../../../../stacks/aws-cluster-access"

  region         = var.region
  project        = var.project
  environment    = var.environment
  cluster_name   = data.terraform_remote_state.cluster.outputs.cluster_name
  node_role_name = local.node_role_name

  # IAM user ARNs from the global IAM user management
  iam_user_arns = data.terraform_remote_state.global_iam_users.outputs.iam_user_arns

  # Same global user list (symlinked from global/users.global.auto.tfvars)
  users = var.users
}
