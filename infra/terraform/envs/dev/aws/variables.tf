# Development Environment Variables - AWS
# These are variable declarations, actual values go in terraform.tfvars

# TODO: Define variables for the environment
#
# variable "environment" {
#   description = "Environment name"
#   type        = string
#   default     = "dev"
# }
#
# variable "region" {
#   description = "AWS region"
#   type        = string
# }
#
# variable "cluster_name" {
#   description = "EKS cluster name"
#   type        = string
# }
#
# variable "kubernetes_version" {
#   description = "Kubernetes version"
#   type        = string
# }
#
# variable "vpc_cidr" {
#   description = "VPC CIDR block"
#   type        = string
# }
#
# variable "availability_zones" {
#   description = "List of availability zones"
#   type        = list(string)
# }
#
# variable "private_subnet_cidrs" {
#   description = "Private subnet CIDR blocks"
#   type        = list(string)
# }
#
# variable "public_subnet_cidrs" {
#   description = "Public subnet CIDR blocks"
#   type        = list(string)
# }
#
# variable "enable_nat_gateway" {
#   description = "Enable NAT gateway"
#   type        = bool
#   default     = true
# }
#
# variable "node_groups" {
#   description = "EKS node group configurations"
#   type        = any
# }
#
# variable "enable_private_endpoint" {
#   description = "Enable private cluster endpoint"
#   type        = bool
#   default     = true
# }
#
# variable "enable_public_endpoint" {
#   description = "Enable public cluster endpoint"
#   type        = bool
#   default     = true
# }
#
# variable "authorized_networks" {
#   description = "CIDR blocks allowed to access public endpoint"
#   type        = list(string)
# }
#
# variable "tags" {
#   description = "Common tags for all resources"
#   type        = map(string)
#   default     = {}
# }

variable "region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "project" {
  type    = string
  default = "hera"
}

variable "environment" {
  type    = string
  default = "dev"
}

# Network variables
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets (cost-effective for dev)"
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = false
}

variable "vpc_endpoints" {
  description = "List of VPC endpoints to create (s3, ecr_api, ecr_dkr, ec2, ec2messages, sts, logs)"
  type        = list(string)
  default     = []
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log retention in days for VPC Flow Logs. Dev: 1 day, Prod: 3 days recommended"
  type        = number
  default     = 1
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log: ACCEPT, REJECT, or ALL"
  type        = string
  default     = "ALL"
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
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
  description = "Enable IAM policy for Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "cluster_log_retention_days" {
  description = "CloudWatch log retention in days for EKS control plane logs"
  type        = number
  default     = 1
}

variable "enable_addons" {
  type    = bool
  default = false
}

variable "enable_irsa" {
  type    = bool
  default = false
}

variable "enable_ebs_csi_driver" {
  type    = bool
  default = false
}

variable "addons" {
  type    = map(any)
  default = {}
}
