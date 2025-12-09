# ==============================================================================
# Namespaces for Environment Separation
# ==============================================================================

resource "kubernetes_namespace_v1" "dev" {
  count = var.environment == "dev" ? 1 : 0

  metadata {
    name = "dev"
    labels = {
      environment = "dev"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "staging" {
  count = var.environment == "staging" ? 1 : 0

  metadata {
    name = "staging"
    labels = {
      environment = "staging"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_namespace_v1" "prod" {
  count = var.environment == "prod" ? 1 : 0

  metadata {
    name = "prod"
    labels = {
      environment = "prod"
      managed-by  = "terraform"
    }
  }
}

# ==============================================================================
# ClusterRole: Infra Manager (Full Cluster Admin)
# ==============================================================================

resource "kubernetes_cluster_role_binding_v1" "infra_manager" {
  metadata {
    name = "${var.project}-${var.environment}-infra-manager"
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
# ClusterRole: Infra Member (Full Cluster Access, No Destructive Ops)
# ==============================================================================

resource "kubernetes_cluster_role_v1" "infra_member" {
  metadata {
    name = "${var.project}-${var.environment}-infra-member"
  }

  # Full read access
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # Create/update (but not delete) in most resources
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources = [
      "pods", "services", "deployments", "replicasets",
      "statefulsets", "daemonsets", "jobs", "cronjobs",
      "configmaps", "secrets", "persistentvolumeclaims",
    ]
    verbs = ["create", "update", "patch"]
  }

  # Allow exec/logs for debugging
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/exec"]
    verbs      = ["get", "list", "create"]
  }

  # Network policies
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "infra_member" {
  metadata {
    name = "${var.project}-${var.environment}-infra-member"
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
# ClusterRole: Developer (Environment-Specific Access)
# ==============================================================================

# ClusterRole for read-only cluster-wide (for non-dev environments)
resource "kubernetes_cluster_role_v1" "developer_readonly" {
  metadata {
    name = "${var.project}-${var.environment}-developer-readonly"
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions", "networking.k8s.io"]
    resources = [
      "pods", "pods/log", "services", "deployments", "replicasets",
      "statefulsets", "daemonsets", "jobs", "cronjobs",
      "configmaps", "persistentvolumeclaims", "ingresses",
    ]
    verbs = ["get", "list", "watch"]
  }
}

# Namespace-specific Role for full access (dev environment only)
resource "kubernetes_role_v1" "developer_full_access" {
  count = var.environment == "dev" ? 1 : 0

  metadata {
    name      = "${var.project}-developer-full-access"
    namespace = kubernetes_namespace_v1.dev[0].metadata[0].name
  }

  # Full access to application resources
  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources = [
      "pods", "pods/log", "pods/exec", "services", "deployments",
      "replicasets", "statefulsets", "daemonsets", "jobs", "cronjobs",
      "configmaps", "secrets", "persistentvolumeclaims",
    ]
    verbs = ["*"] # Full CRUD + exec
  }

  # Network policies
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["*"]
  }
}

# ClusterRoleBinding for read-only access to all namespaces
resource "kubernetes_cluster_role_binding_v1" "developer_readonly" {
  count = var.environment != "dev" ? 1 : 0

  metadata {
    name = "${var.project}-${var.environment}-developer-readonly"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.developer_readonly.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "hera:developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# RoleBinding for full access to dev namespace (dev env only)
resource "kubernetes_role_binding_v1" "developer_full_access" {
  count = var.environment == "dev" ? 1 : 0

  metadata {
    name      = "${var.project}-developer-full-access"
    namespace = kubernetes_namespace_v1.dev[0].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.developer_full_access[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "hera:developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# ==============================================================================
# ClusterRole: Security Engineer (Read-Only Security Focus)
# ==============================================================================

resource "kubernetes_cluster_role_v1" "security_engineer" {
  metadata {
    name = "${var.project}-${var.environment}-security-engineer"
  }

  # Read-only access to all resources
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  # Read security-related resources
  rule {
    api_groups = ["policy"]
    resources  = ["podsecuritypolicies", "poddisruptionbudgets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["get", "list", "watch"]
  }

  # Read audit logs and events
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "security_engineer" {
  metadata {
    name = "${var.project}-${var.environment}-security-engineer"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.security_engineer.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "hera:security-engineers"
    api_group = "rbac.authorization.k8s.io"
  }
}
