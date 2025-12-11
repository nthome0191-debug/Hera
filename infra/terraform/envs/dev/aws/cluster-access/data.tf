# ==============================================================================
# Data Sources
# ==============================================================================

# EKS cluster data for Kubernetes provider configuration
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Fetch IAM user ARNs from the global IAM user management deployment
data "terraform_remote_state" "global_iam_users" {
  backend = "local"

  config = {
    path = "../../global/aws/iam-users/terraform.tfstate"
  }
}
