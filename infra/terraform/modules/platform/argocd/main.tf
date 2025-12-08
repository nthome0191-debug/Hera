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
        insecure = true
        service = {
          type = "NodePort"
          nodePortHttp = 30080
        }
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

# Git credentials and initial apps should be managed via ArgoCD UI or kubectl
# after the cluster is deployed, not through Terraform

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
