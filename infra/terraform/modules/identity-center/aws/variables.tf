# ==============================================================================
# Identity Center Module Variables
# ==============================================================================

variable "project" {
  description = "Project name used for resource naming"
  type        = string
  default     = "hera"
}

# variable "environment" {
#   description = "Environment name (e.g., dev, staging, prod)"
#   type        = string
#   default     = "global"
# }

# ==============================================================================
# Session Configuration
# ==============================================================================

variable "session_duration" {
  description = "SSO session duration in ISO 8601 format (e.g., PT4H for 4 hours)"
  type        = string
  default     = "PT4H"

  validation {
    condition     = can(regex("^PT[0-9]+[HM]$", var.session_duration))
    error_message = "Session duration must be in ISO 8601 format (e.g., PT1H, PT4H, PT12H)"
  }
}

# ==============================================================================
# User Definitions
# ==============================================================================

variable "users" {
  description = "Map of SSO users to create"
  type = map(object({
    email       = string
    first_name  = string
    last_name   = string
    display_name = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for user in var.users : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", user.email))
    ])
    error_message = "All user emails must be valid email addresses"
  }
}

# ==============================================================================
# Group Definitions
# ==============================================================================

variable "groups" {
  description = "Map of SSO groups with member assignments and permission sets"
  type = map(object({
    description     = string
    members         = list(string)
    permission_sets = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for group in var.groups : alltrue([
        for ps in group.permission_sets : contains([
          "InfraManager",
          "InfraMember",
          "Developer",
          "SecurityEngineer"
        ], ps)
      ])
    ])
    error_message = "Permission sets must be one of: InfraManager, InfraMember, Developer, SecurityEngineer"
  }
}

# ==============================================================================
# Permission Set Customization
# ==============================================================================

variable "custom_permission_policies" {
  description = "Map of permission set names to custom inline policy JSON (optional)"
  type        = map(string)
  default     = {}
}

variable "enable_permission_boundary" {
  description = "Enable permission boundary on all permission sets"
  type        = bool
  default     = false
}

variable "permission_boundary_arn" {
  description = "ARN of the permission boundary policy (if enabled)"
  type        = string
  default     = null
}

# ==============================================================================
# Tags
# ==============================================================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
