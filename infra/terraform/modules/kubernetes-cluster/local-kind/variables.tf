variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path where kubeconfig will be written"
  type        = string
  default     = "~/.kube/config"
}

variable "tags" {
  description = "Tags to apply to resources (for consistency with cloud modules)"
  type        = map(string)
  default     = {}
}

variable "worker_groups" {
  type = list(object({
    count  = number
    labels = map(string)
  }))

  default = []
}

