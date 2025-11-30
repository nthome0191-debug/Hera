# Remote State Configuration - AWS Dev Environment

# TODO: Configure S3 backend for remote state
# Uncomment and configure when ready to use remote state
#
# terraform {
#   backend "s3" {
#     bucket         = "hera-terraform-state-dev"
#     key            = "dev/aws/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "hera-terraform-locks"
#   }
# }
#
# Note: Create the S3 bucket and DynamoDB table manually before using this backend
# S3 bucket: Enable versioning and encryption
# DynamoDB table: Create with LockID as partition key (String)
