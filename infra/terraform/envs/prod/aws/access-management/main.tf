provider "aws" {
  region = var.region
}

# Get EKS cluster info from remote state
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "hera-${var.environment}-tf-state-${var.aws_account_id}"
    key    = "${var.environment}/aws/cluster/terraform.tfstate"
    region = var.region
  }
}

# Get EKS cluster authentication
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Instantiate access management module
module "access_management" {
  source = "../../../../modules/access-management/aws"

  environment    = var.environment
  region         = var.region
  aws_account_id = var.aws_account_id
  project        = var.project

  cluster_name   = data.terraform_remote_state.cluster.outputs.cluster_name
  node_role_name = data.terraform_remote_state.cluster.outputs.node_iam_role_name

  users = var.users

  enforce_password_policy = var.enforce_password_policy
  enforce_mfa            = var.enforce_mfa
  allowed_ip_ranges      = var.allowed_ip_ranges
  verify_cloudtrail      = var.verify_cloudtrail

  tags = var.tags
}
