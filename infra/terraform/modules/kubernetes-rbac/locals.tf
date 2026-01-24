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
  standard_write_rules = [
    {
      api_groups = ["", "apps", "batch", "extensions"]
      resources = [
        "pods", "services", "deployments", "replicasets",
        "statefulsets", "daemonsets", "jobs", "cronjobs",
        "configmaps", "persistentvolumeclaims",
      ]
      verbs = ["create", "update", "patch", "delete"]
    },
    {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = [""]
      resources  = ["pods/log", "pods/exec", "pods/portforward"]
      verbs      = ["get", "list", "create"]
    }
  ]
}
