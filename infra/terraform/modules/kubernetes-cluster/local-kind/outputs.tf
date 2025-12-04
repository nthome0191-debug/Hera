output "cluster_name" {
  description = "Name of the kind cluster"
  value       = kind_cluster.main.name
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = kind_cluster.main.endpoint
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = kind_cluster.main.kubeconfig_path
}

output "client_certificate" {
  description = "Client certificate for cluster access"
  value       = kind_cluster.main.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for cluster access"
  value       = kind_cluster.main.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = kind_cluster.main.cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = kind_cluster.main.kubeconfig
  sensitive   = true
}

output "kubeconfig_context" {
  description = "Kubeconfig context name for this cluster"
  value       = "kind-${kind_cluster.main.name}"
}
