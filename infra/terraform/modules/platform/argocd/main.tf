locals {
  # Let ArgoCD generate its own password on first install
  # We'll extract it from the argocd-initial-admin-secret
}
resource "kubernetes_namespace" "argocd" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = var.namespace
    labels = var.tags
  }
}

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

resource "kubernetes_manifest" "initial_argocd_app" {
  depends_on = [helm_release.argocd, kubernetes_secret.git_credentials]
  
  count = var.git_repository_url != "" ? 1 : 0
  
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = var.initial_app_name
      "namespace" = var.namespace 
      "labels" = {
        "app.kubernetes.io/name" = var.initial_app_name
      }
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = var.git_repository_url
        "targetRevision" = var.initial_app_target_revision
        "path"           = var.initial_app_path
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = var.initial_app_destination_namespace
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true 
        }
        "syncOptions" = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}

# Data source to read the auto-generated admin password
data "kubernetes_secret" "argocd_initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on = [
    helm_release.argocd
  ]
}
