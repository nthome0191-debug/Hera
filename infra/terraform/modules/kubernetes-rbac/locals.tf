# ==============================================================================
# Local Values
# ==============================================================================

locals {
  # Common labels for Kubernetes resources
  common_labels = merge(
    var.tags,
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = var.project
      "app.kubernetes.io/component"  = "rbac"
      "environment"                  = var.environment
    }
  )
}
