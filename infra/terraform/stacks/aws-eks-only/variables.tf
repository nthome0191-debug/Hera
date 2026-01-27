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
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Cluster configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_type" {
  description = "Type of cluster: apps, pci, analytics, infra"
  type        = string
  default     = "apps"
}

variable "deployment_mode" {
  description = "AZ deployment mode: single-az or multi-az"
  type        = string
  default     = "multi-az"
}

variable "primary_az" {
  description = "Primary AZ for single-az deployments (e.g., us-east-1a)"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "kubeconfig_context_name" {
  description = "Custom kubeconfig context name"
  type        = string
  default     = ""
}

# Network (from existing VPC)
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

# API endpoints
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

# Node groups
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

# Cluster features
variable "enable_cluster_autoscaler" {
  description = "Enable IAM policy for Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "use_random_suffix" {
  description = "Add random suffix to EKS resources"
  type        = bool
  default     = true
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

variable "karpenter_version" {
  description = "The version of Karpenter to deploy"
  type        = string
  default     = "v0.30.4"
}

# Encryption (for PCI clusters)
variable "enable_cluster_encryption" {
  description = "Enable envelope encryption of Kubernetes secrets using KMS"
  type        = bool
  default     = false
}

variable "cluster_encryption_kms_key_id" {
  description = "KMS key ID for cluster encryption"
  type        = string
  default     = ""
}

# Cross-cluster communication
variable "peer_cluster_security_group_ids" {
  description = "List of node security group IDs from other clusters for cross-cluster communication"
  type        = list(string)
  default     = []
}
