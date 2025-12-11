module "aws_iam_users" {
  source = "../../../../stacks/aws-iam-users"

  region         = var.region
  aws_account_id = var.aws_account_id
  project        = var.project

  users                   = var.users
  enforce_password_policy = var.enforce_password_policy
  enforce_mfa             = var.enforce_mfa
  allowed_ip_ranges       = var.allowed_ip_ranges
}
