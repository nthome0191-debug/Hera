output "namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.namespace
}

output "admin_password" {
  description = "ArgoCD admin password"
  value       = local.admin_password
  sensitive   = true
}

output "server_service" {
  description = "ArgoCD server service name"
  value       = "argocd-server"
}

output "kubectl_port_forward" {
  description = "Port-forward command for ArgoCD UI"
  value       = "kubectl port-forward -n ${var.namespace} svc/argocd-server 8080:443"
}

output "kubectl_password_command" {
  description = "Command to retrieve the ArgoCD admin password from the Kubernetes cluster."
  value       = "kubectl get secret argocd-admin-access -n ${var.namespace} -o jsonpath='{.data.admin_password}' | base64 -d"
}