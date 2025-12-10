locals {
  bucket_name      = "${var.project}-audit-logs"
  trail_name       = var.cloudtrail_name != null ? var.cloudtrail_name : "${var.project}-trail"
}

# ----------------------------
# S3 Bucket for CloudTrail logs
# ----------------------------
resource "aws_s3_bucket" "audit" {
  count  = var.create_cloudtrail ? 1 : 0
  bucket = local.bucket_name

  tags = merge(var.tags, {
    "Name"        = local.bucket_name
    "Project"     = var.project
  })
}

# Required ACL for CloudTrail
resource "aws_s3_bucket_policy" "audit" {
  count  = var.create_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.audit[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.audit[0].arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.audit[0].arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ----------------------------
# CloudTrail Trail
# ----------------------------
resource "aws_cloudtrail" "main" {
  count                         = var.create_cloudtrail ? 1 : 0
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.audit[0].id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(var.tags, {
    "Name"        = local.trail_name
    "Project"     = var.project
  })
}
