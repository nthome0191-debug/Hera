# ==============================================================================
# Module Outputs
# ==============================================================================

output "sso_role_mappings" {
  description = "SSO role to Kubernetes group mappings"
  value = [
    for entry in local.sso_role_entries : {
      role_arn = entry.rolearn
      username = entry.username
      groups   = entry.groups
    }
  ]
}

output "authentication_mode" {
  description = "Authentication mode (SSO only)"
  value       = "sso"
}

output "aws_auth_configmap_name" {
  description = "Name of the aws-auth ConfigMap"
  value       = "aws-auth"
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access via SSO"
  value = templatefile("${path.module}/templates/user-onboarding.tpl", {
    cluster_name   = var.cluster_name
    region         = var.region
    environment    = var.environment
    project        = var.project
    aws_account_id = data.aws_caller_identity.current.account_id
  })
}
