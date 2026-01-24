variable "region" {
  description = "AWS region for this cluster"
  type        = string
}

variable "project" {
  description = "Project name (for tagging and naming)"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (dev/staging/prod) - affects RBAC permissions"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cluster_name" {
  description = "EKS cluster name to configure access for"
  type        = string
}

# ==============================================================================
# SSO Role ARNs (Required)
# ==============================================================================

variable "sso_role_arns" {
  description = "Map of permission set names to their IAM role ARNs (from identity-center module)"
  type        = map(string)
}