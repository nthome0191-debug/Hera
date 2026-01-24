# ==============================================================================
# Environment Variables
# ==============================================================================

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
