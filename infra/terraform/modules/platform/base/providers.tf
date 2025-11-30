# TODO: Configure Kubernetes and Helm providers
#
# Required providers:
# - kubernetes: For managing Kubernetes resources
# - helm: For deploying Helm charts
#
# Provider configuration will use credentials from the kubernetes-cluster module
# Example:
# provider "kubernetes" {
#   host                   = var.cluster_endpoint
#   cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
#   token                  = var.cluster_token  # or use exec config
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = var.cluster_endpoint
#     cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
#     token                  = var.cluster_token
#   }
# }
