locals {
  admin_password = var.admin_password != "" ? var.admin_password : random_password.admin.result
}

# -----------------------------
# Random admin password if not provided
# -----------------------------

resource "random_password" "admin" {
  length  = 16
  special = true
}

# -----------------------------
# Namespace (optional)
# -----------------------------

resource "kubernetes_namespace" "argocd" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = var.namespace
    labels = var.tags
  }
}

# -----------------------------
# Install ArgoCD via Helm
# -----------------------------

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  depends_on = [
    kubernetes_namespace.argocd
  ]

  values = var.values != "" ? [var.values] : [
    yamlencode({
      crds = {
        install = true
        keep    = true
      }
      server = {
        replicas = 1
      }
      repoServer = {
        replicas = 1
      }
      controller = {
        replicas = 1
      }
      redis = {
        enabled = true
      }
    })
  ]

  wait          = true
  wait_for_jobs = true
  timeout       = 600
}

# -----------------------------
# Override initial admin password
# -----------------------------

resource "kubernetes_secret" "admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    password = local.admin_password
  }

  depends_on = [
    helm_release.argocd
  ]

  lifecycle {
    ignore_changes = [data]
  }
}

# -----------------------------
# Git Credentials Secret for ArgoCD
# -----------------------------

resource "kubernetes_secret" "git_credentials" {
  metadata {
    name      = "git-repository-credentials"
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.git_repository_url
    username = var.git_repository_username
    password = var.git_repository_password
  }

  depends_on = [
    helm_release.argocd
  ]
}
