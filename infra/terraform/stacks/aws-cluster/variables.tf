# Global variables shared by network + eks

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

variable "enable_flow_logs" {
  type    = bool
  default = false
}

variable "flow_logs_retention_days" {
  type    = number
  default = 1
}

variable "flow_logs_traffic_type" {
  type    = string
  default = "ALL"
}

# EKS variables

variable "cluster_name" {
  type    = string
  default = ""
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "enable_private_endpoint" {
  type    = bool
  default = true
}

variable "enable_public_endpoint" {
  type    = bool
  default = true
}

variable "authorized_networks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "node_groups" {
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
  type    = bool
  default = false
}

variable "cluster_log_retention_days" {
  type    = number
  default = 1
}

variable "enable_irsa" {
  type    = bool
  default = true
}

variable "use_random_suffix" {
  type    = bool
  default = true
}

variable "eks_addons" {
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
  default = {
    vpc_cni = {
      enabled                  = true
      version                  = "latest"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    kube_proxy = {
      enabled                  = true
      version                  = "latest"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    coredns = {
      enabled                  = true
      version                  = "latest"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    aws_ebs_csi_driver = {
      enabled                  = true
      version                  = "latest"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
  }
}

variable "karpenter_version" {
  description = "The version of Karpenter to deploy"
  type        = string
  default     = "v0.30.4"
}

variable "kubeconfig_context_name" {
  description = "Friendly kubeconfig context name for this environment"
  type        = string
}

variable "create_cloudtrail" {
  type        = bool
  default     = false
  description = "Whether to create CloudTrail and its audit S3 bucket in this environment"
}

variable "cloudtrail_name" {
  type        = string
  default     = null
  description = "Optional override for CloudTrail trail name"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
