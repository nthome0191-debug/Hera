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
  default     = "1.32"
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

variable "eks_addons" {
  description = "EKS addons configuration. Each addon can be enabled/disabled individually with specific versions"
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
      version                  = "v1.18.1-eksbuild.3"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    kube_proxy = {
      enabled                  = true
      version                  = "v1.32.0-eksbuild.5"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    coredns = {
      enabled                  = true
      version                  = "v1.11.3-eksbuild.2"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
    aws_ebs_csi_driver = {
      enabled                  = true
      version                  = "v1.37.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = ""
    }
  }
}

variable "enable_cluster_autoscaler" {
  description = "Enable IAM policy for Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "use_random_suffix" {
  description = "Add random suffix to EKS resources to avoid naming conflicts during destroy/recreate cycles"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kubeconfig_context_name" {
  description = "If set, rename the kubeconfig context to this name. If empty, no renaming occurs."
  type        = string
  default     = ""
}
