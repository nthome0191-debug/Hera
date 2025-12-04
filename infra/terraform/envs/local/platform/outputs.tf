output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = module.argocd.namespace
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.argocd.admin_password
  sensitive   = true
}

output "argocd_server_service" {
  description = "ArgoCD server service name"
  value       = module.argocd.server_service
}

output "argocd_port_forward_command" {
  description = "Command to port-forward to ArgoCD UI"
  value       = module.argocd.kubectl_port_forward
}

output "argocd_access_info" {
  description = "How to access ArgoCD"
  value = {
    url      = "https://localhost:8080"
    username = "admin"
    password_command = "terraform output -raw argocd_admin_password"
  }
}
