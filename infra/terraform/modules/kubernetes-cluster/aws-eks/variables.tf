terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS cluster and nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for load balancers"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "enable_public_endpoint" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "CIDR blocks allowed to access public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention in days for EKS control plane logs"
  type        = number
  default     = 7
}

variable "node_groups" {
  description = "Map of EKS node group configurations"
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

variable "enable_cluster_encryption" {
  description = "Enable envelope encryption of Kubernetes secrets using KMS"
  type        = bool
  default     = false
}

variable "cluster_encryption_kms_key_id" {
  description = "KMS key ID for cluster encryption (if enable_cluster_encryption is true)"
  type        = string
  default     = ""
}

variable "enable_addons" {
  description = "Enable EKS addons"
  type        = bool
  default     = true
}

variable "addons" {
  description = "Map of EKS addon configurations"
  type = map(object({
    version                  = string
    resolve_conflicts        = string
    service_account_role_arn = string
  }))
  default = {}
}

variable "enable_cluster_autoscaler" {
  description = "Enable IAM policy for Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver addon"
  type        = bool
  default     = true
}

variable "enable_efs_csi_driver" {
  description = "Enable EFS CSI driver addon"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
