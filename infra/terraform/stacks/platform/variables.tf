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

########################################
# Future Platform Services Variables
########################################

# TODO: Add Istio variables when implementing
# variable "istio_enabled" {
#   description = "Enable Istio service mesh"
#   type        = bool
#   default     = false
# }

# TODO: Add Kafka variables when implementing
# variable "kafka_enabled" {
#   description = "Enable Kafka"
#   type        = bool
#   default     = false
# }
