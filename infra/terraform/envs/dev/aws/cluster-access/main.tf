module "aws_cluster_access" {
  source = "../../../../stacks/aws-cluster-access"

  region         = var.region
  project        = var.project
  environment    = var.environment
  cluster_name   = data.terraform_remote_state.cluster.outputs.cluster_name

  # SSO role ARNs from Identity Center (K8s group mapping is done in cluster-auth-mapping)
  sso_role_arns = data.terraform_remote_state.identity_center.outputs.sso_role_arns
}
