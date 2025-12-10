# ==============================================================================
# IAM User Management Module - Variables
# ==============================================================================
# This module manages IAM users, groups, and policies.
# It is environment-agnostic and creates global IAM resources.
# ==============================================================================

variable "project" {
  description = "Project name"
  type        = string
  default     = "hera"
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

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
