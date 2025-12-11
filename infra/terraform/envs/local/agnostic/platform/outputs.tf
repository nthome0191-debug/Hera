output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = module.platform.argocd_namespace
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.platform.argocd_admin_password
  sensitive   = true
}
