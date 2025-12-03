
output "namespace" {
  description = "Kubernetes namespace where Gitea is deployed"
  value       = var.namespace
}

output "admin_username" {
  description = "Gitea admin username"
  value       = var.admin_username
}

output "admin_password" {
  description = "Gitea admin password"
  value       = local.admin_password
  sensitive   = true
}

output "service_url" {
  description = "Gitea in-cluster service URL"
  value       = local.service_url
}

output "service_name" {
  description = "Gitea HTTP service name"
  value       = "gitea-http"
}

output "kubectl_port_forward" {
  description = "kubectl command to access Gitea UI"
  value       = "kubectl port-forward -n ${var.namespace} svc/gitea-http 3000:3000"
}
