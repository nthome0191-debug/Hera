# ==============================================================================
# AWS EKS Auth Mapping Module - Variables
# ==============================================================================
# This module manages the aws-auth ConfigMap for EKS clusters.
# It maps IAM identities to Kubernetes users/groups.
# ==============================================================================

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_role_name" {
  description = "IAM role name for EKS nodes (required for nodes to join cluster)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "hera"
}

variable "iam_user_arns" {
  description = "Map of IAM user ARNs (from iam-user-management module)"
  type        = map(string)
}

variable "users" {
  description = "Map of users with their roles (for group mapping)"
  type = map(object({
    email               = string
    full_name           = string
    roles               = list(string)
    require_mfa         = bool
    console_access      = bool
    programmatic_access = bool
    environments        = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
