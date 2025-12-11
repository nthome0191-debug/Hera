# Bootstrap Environment Variables - AWS

variable "region" {
  description = "AWS region where bootstrap resources will be created"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID for IAM role configuration"
  type        = string
}

variable "project" {
  description = "Project name (used in resource naming)"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (used in resource naming)"
  type        = string
  default     = "bootstrap"
}
