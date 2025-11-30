variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_force_destroy" {
  type    = bool
  default = false
}

variable "bucket_versioning" {
  type    = string
  default = "Enabled"
}

variable "bucket_sse_algo" {
  type    = string
  default = "AES256"
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

variable "lock_table_name" {
  type = string
}

variable "lock_table_hash_key" {
  type    = string
  default = "LockID"
}

variable "lock_table_hash_key_type" {
  type    = string
  default = "S"
}

variable "lock_table_billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "create_admin_role" {
  type    = bool
  default = true
}

variable "admin_role_name" {
  type    = string
}

variable "admin_principal_arn" {
  type = string
}

variable "admin_policy_arn" {
  type    = string
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "tags" {
  type    = map(string)
  default = {}
}
