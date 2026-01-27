
data "terraform_remote_state" "cluster" {
  backend = "s3" 
  config = {
    bucket = var.remote_state_bucket
    key    = "envs/dev/aws/cluster/terraform.tfstate"
    region = var.region
  }
}

module "karpenter" {
  source = "../../../../modules/karpenter"

  # Use the data from the remote state
  cluster_name      = data.terraform_remote_state.cluster.outputs.cluster_name
  cluster_endpoint  = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  oidc_provider_arn = data.terraform_remote_state.cluster.outputs.oidc_provider_arn
  
  cluster_certificate_authority_data = data.terraform_remote_state.cluster.outputs.cluster_ca_certificate
}