variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
}

variable "worker_nodes" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
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
