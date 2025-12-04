variable "project" {
  type        = string
  default     = "hera"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

##############################
# Kubernetes access
##############################

variable "kubeconfig_path" {
  description = "Path to kubeconfig file for the dev cluster"
  type        = string
}

##############################
# ArgoCD / GitOps settings
##############################

variable "git_repository_url" {
  description = "HTTPS Git repository used by ArgoCD"
  type        = string
}

variable "git_repository_username" {
  description = "Git repository username"
  type        = string
}

variable "git_repository_password" {
  description = "Git repository password/token"
  type        = string
  sensitive   = true
}

variable "argocd_admin_password" {
  description = "Admin password for ArgoCD (empty = auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_values" {
  description = "Optional Helm values for ArgoCD"
  type        = string
  default     = ""
}
