variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account ID must be a 12-digit number."
  }
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "hera"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_role_name" {
  description = "IAM role name for EKS nodes (from cluster module)"
  type        = string
}

variable "users" {
  description = "Map of users to their role assignments"
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

  validation {
    condition = alltrue([
      for user in var.users : alltrue([
        for role in user.roles :
        contains(["infra-manager", "infra-member", "developer", "security-engineer"], role)
      ])
    ])
    error_message = "User roles must be one of: infra-manager, infra-member, developer, security-engineer."
  }
}

variable "enforce_password_policy" {
  description = "Enforce strict password policy"
  type        = bool
  default     = true
}

variable "enforce_mfa" {
  description = "Enforce MFA for all users"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for console access (empty = no restriction)"
  type        = list(string)
  default     = []
}

variable "verify_cloudtrail" {
  description = "Verify CloudTrail is enabled for audit logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
