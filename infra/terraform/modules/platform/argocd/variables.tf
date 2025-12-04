# =======================================
# Core
# =======================================

variable "namespace" {
  description = "Namespace in which ArgoCD will be installed"
  type        = string
  default     = "argocd"
}

variable "create_namespace" {
  description = "Create namespace if it does not exist"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Labels/tags to attach to namespace resources"
  type        = map(string)
  default     = {}
}

# =======================================
# ArgoCD Helm Chart
# =======================================

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "values" {
  description = "Values to pass to Helm chart (YAML string)"
  type        = string
  default     = ""
}

# =======================================
# Admin Password (optional)
# =======================================

variable "admin_password" {
  description = "Admin password for ArgoCD (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

# =======================================
# Git Repository Credentials
# =======================================

variable "git_repository_url" {
  description = "HTTPS Git repository URL for GitOps"
  type        = string
}

variable "git_repository_username" {
  description = "Username for Git repository"
  type        = string
}

variable "git_repository_password" {
  description = "Password/token for Git repository"
  type        = string
  sensitive   = true
}
