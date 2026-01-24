# ==============================================================================
# Environment Variables
# ==============================================================================

variable "project" {
  description = "Project name"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "session_duration" {
  description = "Session duration for MFA authentication"
  type = string
  default = "PT8H"
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
