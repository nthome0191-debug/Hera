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
  description = "Path to kubeconfig file for the cluster"
  type        = string
}

variable "kubeconfig_context" {
  description = "Kubeconfig context name to use (optional, defaults to current context)"
  type        = string
  default     = ""
}

##############################
# ArgoCD settings
##############################

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.12"
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
