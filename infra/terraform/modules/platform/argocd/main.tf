
resource "random_password" "admin" {
  count   = var.admin_password == "" ? 1 : 0
  length  = 16
  special = true
}

locals {
  admin_password = var.admin_password != "" ? var.admin_password : random_password.admin[0].result
}

resource "kubernetes_namespace" "argocd" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
    labels = merge(
      var.tags,
      {
        name = var.namespace
      }
    )
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = var.namespace

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

  wait    = true
  timeout = 600
}

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

  depends_on = [kubernetes_namespace.argocd]

  lifecycle {
    ignore_changes = [data]
  }
}


resource "kubernetes_secret" "git_repository" {
  count = var.git_repository_url != "" && var.git_repository_username != "" && var.git_repository_password != "" ? 1 : 0

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

  depends_on = [helm_release.argocd]
}
