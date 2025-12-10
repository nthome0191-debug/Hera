# ==============================================================================
# Kubernetes RBAC Module - Variables (Cloud-Agnostic)
# ==============================================================================
# This module creates Kubernetes ClusterRoles and ClusterRoleBindings.
# It works with ANY Kubernetes cluster (EKS, AKS, GKE, on-prem).
# ==============================================================================

variable "environment" {
  description = "Environment name (dev, staging, prod) - affects permissions"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project" {
  description = "Project name (used for resource naming)"
  type        = string
  default     = "hera"
}

variable "user_mappings" {
  description = "List of users to map to Kubernetes groups (from cluster-auth-mapping module)"
  type = list(object({
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Common tags/labels for resources"
  type        = map(string)
  default     = {}
}
