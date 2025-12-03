
resource "random_password" "admin" {
  count   = var.admin_password == "" ? 1 : 0
  length  = 16
  special = true
}

locals {
  admin_password = var.admin_password != "" ? var.admin_password : random_password.admin[0].result
  service_url    = "http://gitea-http.${var.namespace}.svc.cluster.local:3000"
}

resource "kubernetes_namespace" "gitea" {
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

resource "helm_release" "gitea" {
  name       = "gitea"
  repository = "https://dl.gitea.com/charts"
  chart      = "gitea"
  version    = var.chart_version
  namespace  = var.namespace

  depends_on = [kubernetes_namespace.gitea]

  values = var.values != "" ? [var.values] : [
    yamlencode({
      persistence = {
        enabled = true
        size    = "10Gi"
      }
      postgresql = {
        enabled = true
        persistence = {
          size = "5Gi"
        }
      }
      gitea = {
        admin = {
          username = var.admin_username
          password = local.admin_password
          email    = var.admin_email
        }
        config = {
          server = {
            DOMAIN   = "gitea.${var.namespace}.svc.cluster.local"
            ROOT_URL = local.service_url
          }
        }
      }
      service = {
        http = {
          type = "ClusterIP"
          port = 3000
        }
      }
    })
  ]

  wait          = true
  wait_for_jobs = true
  timeout       = 600
}
