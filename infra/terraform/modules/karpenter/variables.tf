variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "The CA data for the EKS cluster"
  type        = string
}

variable "karpenter_version" {
  description = "The version of Karpenter to deploy"
  type        = string
  default     = "v0.30.4"
}