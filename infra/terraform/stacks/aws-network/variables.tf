
variable "environment" {
  type        = string
  description = "e.g., prod, staging, dev"
}

variable "region" {
  type        = string
  description = "AWS Region for the provider"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to be used within the region"
}

variable "clusters" {
  description = "A list of cluster configurations to provision"
  type = list(object({
    name    = string
    azs     = list(string)
    version = optional(string, "1.31") 
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