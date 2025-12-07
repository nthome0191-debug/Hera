output "argocd_namespace" {
  value       = module.platform.argocd_namespace
  description = "Namespace where ArgoCD is installed"
}

output "argocd_admin_password" {
  value       = module.platform.argocd_admin_password
  sensitive   = true
}

output "argocd_port_forward" {
  value       = module.platform.argocd_port_forward_command
  description = "Command to port-forward ArgoCD UI"
}

output "argocd_access_info" {
  description = "How to access ArgoCD"
  value       = module.platform.argocd_access_info
}
