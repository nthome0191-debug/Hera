variable "region"   { type = string }
variable "vpc_name" { type = string }
variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "clusters" {
  description = "List of EKS clusters to carve subnets for"
  type = list(object({
    name = string
    azs  = list(string)
  }))
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Set to true to share 1 NAT across all clusters/AZs (cheaper for Dev)"
}
