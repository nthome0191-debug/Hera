variable "namespace" {
  type        = string
  default     = "argocd"
}

variable "create_namespace" {
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "chart_version" {
  type        = string
  default     = "5.51.6"
}

variable "values" {
  type        = string
  default     = ""
}

variable "admin_password" {
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_repository_url" {
  type        = string
  default     = ""
}

variable "git_repository_username" {
  type        = string
  default     = ""
}

variable "git_repository_password" {
  type        = string
  default     = ""
  sensitive   = true
}

# Internal dependency injection
variable "_platform_depends_on" {
  description = "Internal: ensures ArgoCD deploys after Gitea and the GitOps repo"
  type        = list(any)
  default     = []
}
