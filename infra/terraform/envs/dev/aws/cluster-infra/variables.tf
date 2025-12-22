# Global variables
variable "region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Cluster variables
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_type" {
  description = "Type of cluster: apps, pci, analytics, infra"
  type        = string
}

variable "deployment_mode" {
  description = "AZ deployment mode: single-az or multi-az"
  type        = string
}

variable "primary_az" {
  description = "Primary AZ for single-az deployments"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "node_groups" {
  description = "Node group configurations"
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
}

variable "eks_addons" {
  description = "EKS addons configuration"
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
      version                  = "v1.20.5-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    kube_proxy = {
      enabled                  = true
      version                  = "v1.32.9-eksbuild.2"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    coredns = {
      enabled                  = true
      version                  = "v1.11.4-eksbuild.24"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    aws_ebs_csi_driver = {
      enabled                  = true
      version                  = "v1.53.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
  }
}

variable "enable_irsa" {
  description = "Enable IRSA (IAM Roles for Service Accounts)"
  type        = bool
  default     = true
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}
