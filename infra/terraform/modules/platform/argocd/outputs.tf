output "namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.namespace
}

output "admin_username" {
  description = "ArgoCD admin username"
  value       = "admin"
}

output "admin_password" {
  description = "ArgoCD admin password"
  value       = data.kubernetes_secret.argocd_initial_admin.data["password"]
  sensitive   = true
}

output "server_service" {
  description = "ArgoCD server service name"
  value       = "argocd-server"
}

output "kubectl_password_command" {
  description = "Command to retrieve the ArgoCD admin password from the Kubernetes cluster."
  value       = "kubectl get secret argocd-initial-admin-secret -n ${var.namespace} -o jsonpath='{.data.password}' | base64 -d"
}