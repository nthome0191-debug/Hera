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

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}
