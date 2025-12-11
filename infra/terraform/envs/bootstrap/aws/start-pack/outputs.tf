# Bootstrap Environment Outputs - AWS
# These outputs are used to configure the backend for other environments

output "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.bootstrap.bucket_name
}

output "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.bootstrap.lock_table_name
}

output "admin_role_arn" {
  description = "ARN of the IAM admin role"
  value       = module.bootstrap.admin_role_arn
}

output "backend_config" {
  description = "Backend configuration for other environments"
  value = {
    bucket         = module.bootstrap.bucket_name
    region         = var.region
    dynamodb_table = module.bootstrap.lock_table_name
    encrypt        = true
  }
}
