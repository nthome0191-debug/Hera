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

variable "node_role_name" {
  description = "EKS node IAM role name (required for aws-auth ConfigMap)"
  type        = string
}

variable "iam_user_arns" {
  description = "Map of IAM user ARNs from the global IAM user management"
  type        = map(string)
}

variable "users" {
  description = "Map of users to their role assignments (same as global user list)"
  type = map(object({
    email               = string
    full_name           = string
    roles               = list(string)
    require_mfa         = bool
    console_access      = bool
    programmatic_access = bool
    environments        = list(string)
  }))
}
