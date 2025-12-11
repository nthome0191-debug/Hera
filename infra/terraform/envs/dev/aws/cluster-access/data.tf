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

# Fetch IAM user ARNs from the global IAM user management deployment
data "terraform_remote_state" "global_iam_users" {
  backend = "local"

  config = {
    path = "../../../global/aws/iam-users/terraform.tfstate"
  }
}
