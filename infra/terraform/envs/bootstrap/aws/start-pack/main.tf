# Bootstrap Environment - AWS
# This creates the foundational infrastructure for Terraform state management
# Must be applied FIRST before any other environments
#
# This creates:
# - S3 bucket for Terraform state storage
# - DynamoDB table for state locking
# - IAM admin role for managing infrastructure

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Hera/Terraform"
    }
  }
}

locals {
  project     = var.project
  environment = var.environment
  suffix = var.aws_account_id

  bucket_name     = "${local.project}-${local.environment}-tf-state-${local.suffix}"
  lock_table_name = "${local.project}-${local.environment}-tf-lock-${local.suffix}"
  admin_role_name = "${local.project}-${local.environment}-admin-${local.suffix}"
}

module "bootstrap" {
  source = "../../../modules/bootstrap/aws"

  region = var.region

  bucket_name          = local.bucket_name
  bucket_force_destroy = false
  bucket_versioning    = "Enabled"
  bucket_sse_algo      = "AES256"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lock_table_name         = local.lock_table_name
  lock_table_hash_key     = "LockID"
  lock_table_hash_key_type = "S"
  lock_table_billing_mode  = "PAY_PER_REQUEST"

  create_admin_role   = true
  admin_role_name     = local.admin_role_name
  admin_principal_arn = "arn:aws:iam::${var.aws_account_id}:root"
  admin_policy_arn    = "arn:aws:iam::aws:policy/AdministratorAccess"

  tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    Layer       = "Bootstrap"
  }
}
