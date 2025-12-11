variable "region" {
  description = "AWS region for this cluster"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name (for tagging and naming)"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name to configure access for"
  type        = string
}

variable "node_role_name" {
  description = "EKS node IAM role name"
  type        = string
}

variable "users" {
  description = "Map of users to their role assignments (from global user list)"
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
