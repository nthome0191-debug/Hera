output "gitea_namespace" {
  description = "Namespace where Gitea is installed"
  value       = module.gitea.namespace
}

output "gitea_service_url" {
  description = "In-cluster URL for Gitea"
  value       = module.gitea.service_url
}

output "gitea_admin_username" {
  description = "Gitea admin username"
  value       = module.gitea.admin_username
}

output "gitea_admin_password" {
  description = "Gitea admin password"
  value       = module.gitea.admin_password
  sensitive   = true
}

output "gitops_repo_clone_url" {
  description = "Git clone URL for the GitOps repository"
  value       = module.gitops_repository.clone_url
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = module.argocd.namespace
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.argocd.admin_password
  sensitive   = true
}

output "argocd_port_forward" {
  description = "Port-forward command to reach ArgoCD UI"
  value       = module.argocd.kubectl_port_forward
}
