output "argocd_namespace" {
  value       = module.platform.argocd_namespace
  description = "Namespace where ArgoCD is installed"
}

output "argocd_admin_password" {
  value       = module.platform.argocd_admin_password
  sensitive   = true
  description = "ArgoCD admin password"
}
