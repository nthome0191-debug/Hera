module "aws_users" {
    source = "../../../../stacks/aws-users"

    # Global
    region         = var.region
    aws_account_id = var.aws_account_id
    project        = var.project
    environment    = var.environment

    # User management
    users                  = var.users
    enforce_password_policy = var.enforce_password_policy
    enforce_mfa             = var.enforce_mfa
    allowed_ip_ranges       = var.allowed_ip_ranges
}
