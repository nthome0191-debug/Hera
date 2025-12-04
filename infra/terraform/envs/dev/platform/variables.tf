variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Extra tags/labels to attach where applicable"
  type        = map(string)
  default     = {}
}

############################
# Cluster access
############################

variable "kubeconfig_path" {
  description = "Path to kubeconfig file for this cluster"
  type        = string
}

############################
# Gitea config
############################

variable "gitea_namespace" {
  description = "Namespace for Gitea"
  type        = string
  default     = "git"
}

variable "gitea_admin_username" {
  description = "Gitea admin username"
  type        = string
  default     = "gitea-admin"
}

variable "gitea_admin_password" {
  description = "Gitea admin password (must be provided so Terraform and Helm share it)"
  type        = string
  sensitive   = true
}

variable "gitea_admin_email" {
  description = "Gitea admin email"
  type        = string
  default     = "admin@dev.local"
}

variable "gitea_values" {
  description = "Optional extra Helm values for Gitea (YAML string)"
  type        = string
  default     = ""
}

############################
# ArgoCD config
############################

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password (leave empty to auto-generate in module)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_values" {
  description = "Optional extra Helm values for ArgoCD (YAML string)"
  type        = string
  default     = ""
}
