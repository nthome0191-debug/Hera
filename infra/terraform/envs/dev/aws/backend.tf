# Remote State Configuration - AWS Dev Environment
#
# PREREQUISITE: The S3 bucket and DynamoDB table must exist before initializing this backend.
# These resources are created by the bootstrap environment (envs/bootstrap/aws/).
#
# Initialization Steps:
# 1. First, apply the bootstrap environment to create the S3 bucket and DynamoDB table
# 2. Then run `terraform init` in this directory to configure the backend
# 3. Terraform will use the S3 backend for storing state

terraform {
  backend "s3" {
    bucket         = "hera-dev-tf-state"
    key            = "dev/aws/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hera-dev-tf-lock"
    encrypt        = true
  }
}
