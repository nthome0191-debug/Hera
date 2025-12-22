# Remote state: Network infrastructure
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "hera-bootstrap-tf-state-628987527285"
    key    = "dev/aws/network/terraform.tfstate"
    region = "us-east-1"
  }
}
