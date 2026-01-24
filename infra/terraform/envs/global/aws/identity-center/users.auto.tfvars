# ==============================================================================
# AWS IAM Identity Center - Users and Groups Configuration
# ==============================================================================
# Users defined here will receive email invitations to set up their SSO access.
# They will need to:
#   1. Accept the email invitation
#   2. Set up their password
#   3. Configure MFA (required)
#
# After setup, users can login via: aws sso login --profile <profile-name>
# ==============================================================================

users = {
  "infra_manager_11" = {
    email      = "infra_manager_11@example.com"
    first_name = "Infra"
    last_name  = "Manager"
  }

  "infra_member_22" = {
    email      = "infra_member_22@example.com"
    first_name = "Infra"
    last_name  = "Member"
  }

  "dev11" = {
    email      = "dev11@example.com"
    first_name = "Dev"
    last_name  = "Eleven"
  }

  "security22" = {
    email      = "sec22@example.com"
    first_name = "Security"
    last_name  = "TwoTwo"
  }
}

# ==============================================================================
# Group Definitions
# ==============================================================================
# Groups organize users and assign them to permission sets.
# Users can belong to multiple groups if they need multiple roles.
# ==============================================================================

groups = {
  "infra-managers" = {
    description     = "Infrastructure administrators with full AWS and K8s admin access"
    members         = ["infra_manager_11"]
    permission_sets = ["InfraManager"]
  }

  "infra-members" = {
    description     = "Infrastructure team members with read and modify access"
    members         = ["infra_member_22"]
    permission_sets = ["InfraMember"]
  }

  "developers" = {
    description     = "Development team with Kubernetes-only access (no AWS console)"
    members         = ["dev11"]
    permission_sets = ["Developer"]
  }

  "security-engineers" = {
    description     = "Security team with read-only security services access"
    members         = ["security22"]
    permission_sets = ["SecurityEngineer"]
  }
}
