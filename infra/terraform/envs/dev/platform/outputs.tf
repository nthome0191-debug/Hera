output "argocd_namespace" {
  value       = module.argocd.namespace
  description = "Namespace where ArgoCD is installed"
}

output "argocd_admin_password" {
  value       = module.argocd.admin_password
  sensitive   = true
}

output "argocd_port_forward" {
  value       = module.argocd.kubectl_port_forward
  description = "Command to port-forward ArgoCD UI"
}
