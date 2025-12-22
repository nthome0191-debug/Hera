# Bootstrap Environment Variables - AWS

variable "region" {
  description = "AWS region for the bootstrap resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
    error_message = "The region must be a valid AWS region format (e.g., us-east-1)."
  }
}

variable "aws_account_id" {
  description = "AWS account ID for IAM role configuration"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "hera"
  validation {
    condition     = length(var.project) <= 10 && can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must be lowercase, alphanumeric, and max 10 chars (to avoid long S3 names)."
  }
}

variable "environment" {
  description = "Environment name (used in resource naming)"
  type        = string
  default     = "bootstrap"
}
