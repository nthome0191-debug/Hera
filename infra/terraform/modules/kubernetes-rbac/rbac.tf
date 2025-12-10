# ==============================================================================
# Kubernetes RBAC - Cluster-Scoped Permissions (Cloud-Agnostic)
# ==============================================================================
# All permissions are cluster-wide, not namespace-specific
#
# Access Model:
# - ONLY members (assigned to roles) can access clusters
# - All members get read access cluster-wide (get, list, watch, describe)
#
# Write/Delete Permissions:
# - Infra Manager: Full admin on ALL environments
# - Infra Member: Full CRUD + delete on ALL environments
# - Developer: Full CRUD + delete on DEV only, read-only on staging/prod
# - Security Engineer: Full CRUD + delete on DEV only, read-only on staging/prod
# ==============================================================================

# ==============================================================================
# ClusterRole: Infra Manager (Full Cluster Admin)
# ==============================================================================

resource "kubernetes_cluster_role_binding_v1" "infra_manager" {
  metadata {
    name   = "${var.project}-${var.environment}-infra-manager"
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin" # Use built-in cluster-admin role
  }

  subject {
    kind      = "Group"
    name      = "hera:infra-managers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# ==============================================================================
# ClusterRole: Infra Member (Full Cluster Control)
# ==============================================================================

resource "kubernetes_cluster_role_v1" "infra_member" {
  metadata {
    name   = "${var.project}-${var.environment}-infra-member"
    labels = local.common_labels
  }

  # Full read access to everything
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # Full CRUD on application resources (create, update, patch, delete)
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources = [
      "pods", "services", "deployments", "replicasets",
      "statefulsets", "daemonsets", "jobs", "cronjobs",
      "configmaps", "secrets", "persistentvolumeclaims",
    ]
    verbs = ["create", "update", "patch", "delete"]
  }

  # Allow exec/logs/port-forward for debugging
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/exec", "pods/portforward"]
    verbs      = ["get", "list", "create"]
  }

  # Full CRUD on network resources
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "infra_member" {
  metadata {
    name   = "${var.project}-${var.environment}-infra-member"
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.infra_member.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "hera:infra-members"
    api_group = "rbac.authorization.k8s.io"
  }
}

# ==============================================================================
# ClusterRole: Developer (Environment-Based Permissions)
# ==============================================================================

# Dev Environment: Full CRUD + delete (same as infra member)
resource "kubernetes_cluster_role_v1" "developer_full" {
  count = var.environment == "dev" ? 1 : 0

  metadata {
    name   = "${var.project}-${var.environment}-developer"
    labels = local.common_labels
  }

  # Full read access to everything
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # Full CRUD on application resources (create, update, patch, delete)
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources = [
      "pods", "services", "deployments", "replicasets",
      "statefulsets", "daemonsets", "jobs", "cronjobs",
      "configmaps", "secrets", "persistentvolumeclaims",
    ]
    verbs = ["create", "update", "patch", "delete"]
  }

  # Allow exec/logs/port-forward for debugging
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/exec", "pods/portforward"]
    verbs      = ["get", "list", "create"]
  }

  # Full CRUD on network resources
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Staging/Prod Environment: Read-only
resource "kubernetes_cluster_role_v1" "developer_readonly" {
  count = var.environment != "dev" ? 1 : 0

  metadata {
    name   = "${var.project}-${var.environment}-developer"
    labels = local.common_labels
  }

  # Read-only access to all resources cluster-wide
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # View logs
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "developer" {
  metadata {
    name   = "${var.project}-${var.environment}-developer"
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.environment == "dev" ? kubernetes_cluster_role_v1.developer_full[0].metadata[0].name : kubernetes_cluster_role_v1.developer_readonly[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "hera:developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# ==============================================================================
# ClusterRole: Security Engineer (Environment-Based Permissions)
# ==============================================================================

# Dev Environment: Full CRUD + delete (same as infra member)
resource "kubernetes_cluster_role_v1" "security_engineer_full" {
  count = var.environment == "dev" ? 1 : 0

  metadata {
    name   = "${var.project}-${var.environment}-security-engineer"
    labels = local.common_labels
  }

  # Full read access to everything
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # Full CRUD on application resources (create, update, patch, delete)
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources = [
      "pods", "services", "deployments", "replicasets",
      "statefulsets", "daemonsets", "jobs", "cronjobs",
      "configmaps", "secrets", "persistentvolumeclaims",
    ]
    verbs = ["create", "update", "patch", "delete"]
  }

  # Allow exec/logs/port-forward for debugging
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/exec", "pods/portforward"]
    verbs      = ["get", "list", "create"]
  }

  # Full CRUD on network resources
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Staging/Prod Environment: Read-only
resource "kubernetes_cluster_role_v1" "security_engineer_readonly" {
  count = var.environment != "dev" ? 1 : 0

  metadata {
    name   = "${var.project}-${var.environment}-security-engineer"
    labels = local.common_labels
  }

  # Read-only access to all resources
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # View logs
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "security_engineer" {
  metadata {
    name   = "${var.project}-${var.environment}-security-engineer"
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.environment == "dev" ? kubernetes_cluster_role_v1.security_engineer_full[0].metadata[0].name : kubernetes_cluster_role_v1.security_engineer_readonly[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "hera:security-engineers"
    api_group = "rbac.authorization.k8s.io"
  }
}
