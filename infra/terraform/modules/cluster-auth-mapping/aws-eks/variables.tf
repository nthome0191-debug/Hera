# ==============================================================================
# AWS EKS Auth Mapping Module - Variables
# ==============================================================================
# This module manages the aws-auth ConfigMap for EKS clusters.
# Authentication is via AWS IAM Identity Center (SSO) only.
# K8s RBAC group mapping is handled here (environment-specific).
# ==============================================================================

variable "cluster_name" {
  description = "EKS cluster name"
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

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# SSO Role ARNs (from Identity Center)
# ==============================================================================

variable "sso_role_arns" {
  description = "Map of permission set names to their IAM role ARNs (from identity-center module)"
  type        = map(string)
}
