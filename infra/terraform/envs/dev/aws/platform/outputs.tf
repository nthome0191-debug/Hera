# Gitea Outputs
output "gitea_admin_username" {
  description = "Gitea admin username"
  value       = module.gitea.admin_username
}

output "gitea_admin_password" {
  description = "Gitea admin password"
  value       = module.gitea.admin_password
  sensitive   = true
}

output "gitea_service_url" {
  description = "Gitea in-cluster service URL"
  value       = module.gitea.service_url
}

output "gitea_port_forward" {
  description = "Command to access Gitea UI"
  value       = module.gitea.kubectl_port_forward
}

# Gitea Repository
output "gitea_repository_url" {
  description = "Gitea repository URL for GitOps"
  value       = gitea_repository.gitops.html_url
}

output "gitea_repository_clone_url" {
  description = "Git clone URL for the GitOps repository"
  value       = gitea_repository.gitops.clone_url
}

# ArgoCD Outputs
output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.argocd.admin_password
  sensitive   = true
}

output "argocd_port_forward" {
  description = "Command to access ArgoCD UI"
  value       = module.argocd.kubectl_port_forward
}
