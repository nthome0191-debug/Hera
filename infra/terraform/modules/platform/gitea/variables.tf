variable "namespace" {
  description = "Kubernetes namespace for Gitea"
  type        = string
  default     = "git"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "chart_version" {
  description = "Gitea Helm chart version"
  type        = string
  default     = "10.1.4"
}

variable "admin_username" {
  description = "Gitea admin username"
  type        = string
  default     = "gitea-admin"
}

variable "admin_password" {
  description = "Gitea admin password (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_email" {
  description = "Gitea admin email"
  type        = string
  default     = "admin@gitea.local"
}

variable "values" {
  description = "Additional values to pass to Gitea Helm chart (YAML string)"
  type        = string
  default     = ""
}
