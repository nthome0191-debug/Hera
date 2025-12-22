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

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway"
  type        = bool
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints"
  type        = bool
}

variable "vpc_endpoints" {
  description = "List of VPC endpoints"
  type        = list(string)
}

variable "cluster_names" {
  description = "List of cluster names"
  type        = list(string)
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
