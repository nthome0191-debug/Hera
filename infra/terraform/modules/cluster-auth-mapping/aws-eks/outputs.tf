# ==============================================================================
# Module Outputs
# ==============================================================================

output "user_mappings" {
  description = "Final user to Kubernetes group mappings"
  value = [
    for mapping in local.user_mappings_final : {
      username = mapping.username
      groups   = mapping.groups
    }
  ]
}

output "aws_auth_configmap_name" {
  description = "Name of the aws-auth ConfigMap"
  value       = "aws-auth"
}

output "kubeconfig_instructions" {
  description = "Instructions for setting up kubectl access"
  value = templatefile("${path.module}/templates/user-onboarding.tpl", {
    cluster_name   = var.cluster_name
    region         = var.region
    environment    = var.environment
    console_url    = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
    project        = var.project
    aws_account_id = data.aws_caller_identity.current.account_id
  })
}
