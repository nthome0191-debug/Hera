variable "project" {
  description = "Project name"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "local"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubeconfig context name to use (optional, defaults to current context)"
  type        = string
  default     = ""
}

########################################
# ArgoCD Variables
########################################

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.12"
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password (leave empty for auto-generated)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_values" {
  description = "Custom Helm values for ArgoCD"
  type        = string
  default     = ""
}

variable "git_repository_url" {
  description = "Git repository URL for ArgoCD"
  type        = string
  default     = ""
}

variable "git_repository_username" {
  description = "Git repository username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_repository_password" {
  description = "Git repository password or token"
  type        = string
  default     = ""
  sensitive   = true
}
