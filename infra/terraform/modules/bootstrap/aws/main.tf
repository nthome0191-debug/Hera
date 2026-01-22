terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# resource "aws_s3_bucket" "tf_state" {
#   bucket        = var.bucket_name
#   force_destroy = false

#   tags = var.tags

#   lifecycle {
#     prevent_destroy = true 
#   }
# }

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags
}

resource "aws_iam_role" "admin_role" {
  count = var.create_admin_role ? 1 : 0
  name  = var.admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = var.admin_principal_arn
      }
      Action = "sts:AssumeRole"
      # Best Practice: Add a condition to ensure only your specific 
      # CI/CD or User can assume this role.
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "admin_role_attach" {
  count      = var.create_admin_role ? 1 : 0
  role       = aws_iam_role.admin_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_s3_bucket_policy" "force_ssl" {
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.force_ssl.json
}

data "aws_iam_policy_document" "force_ssl" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}