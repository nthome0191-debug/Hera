########################################
# ArgoCD Outputs
########################################

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = module.argocd.namespace
}

output "argocd_admin_username" {
  description = "ArgoCD admin username"
  value       = module.argocd.admin_username
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

output "argocd_password_command" {
  description = "Command to get ArgoCD admin password"
  value       = module.argocd.kubectl_password_command
}

output "argocd_access_info" {
  description = "How to access ArgoCD"
  value = {
    url              = "https://localhost:8080"
    username         = module.argocd.admin_username
    password_command = module.argocd.kubectl_password_command
    port_forward     = module.argocd.kubectl_port_forward
  }
}

########################################
# Future Platform Services Outputs
########################################

# TODO: Add Istio outputs when implementing
# output "istio_version" {
#   value = module.istio.version
# }

# TODO: Add Kafka outputs when implementing
# output "kafka_brokers" {
#   value = module.kafka.brokers
# }
