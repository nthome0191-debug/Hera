variable "region" {
  description = "AWS region for IAM resources (global, but required for provider)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "project" {
  description = "Project name (for tagging and naming)"
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
