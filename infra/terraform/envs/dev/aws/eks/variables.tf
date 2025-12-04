variable "region" {
  description = "AWS region for this environment"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "project" {
  description = "Project name (for tagging and naming)"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "enable_private_endpoint" {
  description = "Enable private EKS API endpoint"
  type        = bool
  default     = true
}

variable "enable_public_endpoint" {
  description = "Enable public EKS API endpoint"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "CIDRs allowed for public API access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_groups" {
  description = "EKS node group configurations"
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {}
}

variable "enable_cluster_autoscaler" {
  description = "Enable IAM permissions for Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "cluster_log_retention_days" {
  description = "Retention for EKS control plane logs"
  type        = number
  default     = 1
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "use_random_suffix" {
  description = "Append random suffix to avoid naming collisions"
  type        = bool
  default     = true
}

variable "eks_addons" {
  description = "EKS Addons configuration"
  type = object({
    vpc_cni = object({
      enabled                  = bool
      version                  = string
      resolve_conflicts        = string
      service_account_role_arn = string
    })
    kube_proxy = object({
      enabled                  = bool
      version                  = string
      resolve_conflicts        = string
      service_account_role_arn = string
    })
    coredns = object({
      enabled                  = bool
      version                  = string
      resolve_conflicts        = string
      service_account_role_arn = string
    })
    aws_ebs_csi_driver = object({
      enabled                  = bool
      version                  = string
      resolve_conflicts        = string
      service_account_role_arn = string
    })
  })
  default = {}
}
