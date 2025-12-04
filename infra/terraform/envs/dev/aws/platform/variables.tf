
variable "region" {
  description = "AWS region for this environment"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "project" {
  description = "Project name (for tagging and naming)"
  type        = string
  default     = "hera"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}


variable "gitea_admin_username" {
  description = "Admin username for the Gitea installation"
  type        = string
  default     = "gitea-admin"
}

variable "gitea_admin_email" {
  description = "Admin email for Gitea"
  type        = string
  default     = "admin@local"
}

variable "gitea_admin_password" {
  description = "Optional preset password for Gitea admin (random if empty)"
  type        = string
  default     = ""
}

variable "argocd_git_repository_url" {
  description = "Optional Git repository URL for ArgoCD integration"
  type        = string
  default     = ""
}

variable "argocd_git_repository_username" {
  description = "Username for ArgoCD GitOps repo"
  type        = string
  default     = ""
}

variable "argocd_git_repository_password" {
  description = "Password/token for ArgoCD GitOps repo"
  type        = string
  default     = ""
}
