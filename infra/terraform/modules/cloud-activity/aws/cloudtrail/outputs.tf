output "cloudtrail_name" {
  value       = var.create_cloudtrail ? aws_cloudtrail.main[0].name : null
  description = "Name of the created CloudTrail trail, or null"
}

output "cloudtrail_bucket_name" {
  value       = var.create_cloudtrail ? aws_s3_bucket.audit[0].bucket : null
  description = "Bucket used for CloudTrail logs, or null"
}
