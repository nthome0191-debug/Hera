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

# Network variables

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_vpc_endpoints" {
  type    = bool
  default = false
}

variable "vpc_endpoints" {
  type    = list(string)
  default = []
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
  default = {}
}
