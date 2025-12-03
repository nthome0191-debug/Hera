# ============================================
# ArgoCD Outputs
# ============================================

output "namespace" {
  description = "Kubernetes namespace where ArgoCD is deployed"
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
  description = "kubectl command to access ArgoCD UI"
  value       = "kubectl port-forward -n ${var.namespace} svc/argocd-server 8080:443"
}
