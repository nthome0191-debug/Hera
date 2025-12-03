# ============================================
# Core Configuration
# ============================================

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
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

# ============================================
# ArgoCD Configuration
# ============================================

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "values" {
  description = "Values to pass to ArgoCD Helm chart (YAML string)"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "ArgoCD admin password (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

# ============================================
# Git Repository Configuration
# ============================================
# Configure the Git repository that ArgoCD will use for GitOps
#
# Dev Example (with Gitea module):
#   git_repository_url      = module.gitea.service_url
#   git_repository_username = module.gitea.admin_username
#   git_repository_password = module.gitea.admin_password
#
# Prod Example (with GitHub):
#   git_repository_url      = "https://github.com/your-org/gitops-repo"
#   git_repository_username = "github-username"
#   git_repository_password = "<github-token>"
# ============================================

variable "git_repository_url" {
  description = "Git repository URL to configure in ArgoCD"
  type        = string
  default     = ""
}

variable "git_repository_username" {
  description = "Git repository username"
  type        = string
  default     = ""
}

variable "git_repository_password" {
  description = "Git repository password or token"
  type        = string
  default     = ""
  sensitive   = true
}
