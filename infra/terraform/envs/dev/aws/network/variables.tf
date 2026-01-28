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

# Network variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "clusters" {
  description = "List of EKS clusters to carve subnets for"
  type = list(object({
    name = string
    azs  = list(string)
  }))
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
}

variable "flow_logs_retention_days" {
  description = "Flow logs retention in days"
  type        = number
}

variable "flow_logs_traffic_type" {
  description = "Flow logs traffic type"
  type        = string
}
