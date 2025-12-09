variable "create_cloudtrail" {
  type        = bool
  default     = false
  description = "Whether to create CloudTrail and its audit S3 bucket"
}

variable "cloudtrail_name" {
  type        = string
  default     = null
  description = "Override CloudTrail trail name. If null, automatic naming is used."
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
