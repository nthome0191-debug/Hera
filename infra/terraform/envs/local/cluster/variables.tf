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

variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "hera-local"
}

variable "worker_groups" {
  type = list(object({
    count  = number
    labels = map(string)
  }))

  default = []
}


variable "kubeconfig_path" {
  description = "Path where kubeconfig will be written"
  type        = string
  default     = "~/.kube/config"
}

variable "worker_groups" {
  type = list(object({
    count  = number
    labels = map(string)
  }))

  default = []
}
