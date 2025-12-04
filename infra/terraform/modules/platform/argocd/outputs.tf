output "namespace" {
  value = var.namespace
}

output "admin_password" {
  value     = local.admin_password
  sensitive = true
}

output "server_service" {
  value = "argocd-server"
}

output "kubectl_port_forward" {
  value = "kubectl port-forward -n ${var.namespace} svc/argocd-server 8080:443"
}
