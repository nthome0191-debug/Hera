output "cluster_name" {
  description = "Name of the kind cluster"
  value       = module.kind_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.kind_cluster.cluster_endpoint
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = module.kind_cluster.kubeconfig_path
}

output "client_certificate" {
  description = "Client certificate for cluster access"
  value       = module.kind_cluster.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for cluster access"
  value       = module.kind_cluster.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.kind_cluster.cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = module.kind_cluster.kubeconfig
  sensitive   = true
}

output "kubeconfig_context" {
  description = "Kubeconfig context name for this cluster"
  value       = module.kind_cluster.kubeconfig_context
}
