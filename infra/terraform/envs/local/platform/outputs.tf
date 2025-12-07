output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = module.platform.argocd_namespace
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.platform.argocd_admin_password
  sensitive   = true
}

output "argocd_server_service" {
  description = "ArgoCD server service name"
  value       = module.platform.argocd_server_service
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD UI"
  value       = module.platform.argocd_port_forward_command
}

output "argocd_access_info" {
  description = "How to access ArgoCD"
  value       = module.platform.argocd_access_info
}
