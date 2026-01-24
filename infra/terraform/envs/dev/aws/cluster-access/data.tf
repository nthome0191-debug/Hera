# ==============================================================================
# Data Sources
# ==============================================================================

# Fetch cluster information from the cluster deployment
data "terraform_remote_state" "cluster" {
  backend = "local"

  config = {
    path = "../cluster/terraform.tfstate"
  }
}

# Extract node role name from ARN (format: arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME)
locals {
  node_role_name = split("/", data.terraform_remote_state.cluster.outputs.node_iam_role_arn)[1]
}

# EKS cluster data for Kubernetes provider configuration
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

# Fetch SSO role ARNs from the global Identity Center deployment
data "terraform_remote_state" "identity_center" {
  backend = "s3"

  config = {
    bucket = "hera-bootstrap-tf-state-628987527285"
    key    = "global/aws/identity-center/terraform.tfstate"
    region = "us-east-1"
  }
}
