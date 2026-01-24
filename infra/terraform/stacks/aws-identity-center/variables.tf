# ==============================================================================
# Stack Variables
# ==============================================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "session_duration" {
  description = "SSO session duration in ISO 8601 format"
  type        = string
  default     = "PT4H"
}

variable "users" {
  description = "Map of SSO users to create"
  type = map(object({
    email        = string
    first_name   = string
    last_name    = string
    display_name = optional(string)
  }))
  default = {}
}

variable "groups" {
  description = "Map of SSO groups with permission set assignments"
  type = map(object({
    description     = string
    members         = list(string)
    permission_sets = list(string)
  }))
  default = {}
}

variable "custom_permission_policies" {
  description = "Map of permission set names to custom inline policies"
  type        = map(string)
  default     = {}
}

variable "enable_permission_boundary" {
  description = "Enable permission boundary on permission sets"
  type        = bool
  default     = false
}

variable "permission_boundary_arn" {
  description = "Permission boundary ARN if enabled"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
