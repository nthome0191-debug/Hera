terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    gitea = {
      source  = "go-gitea/gitea"
      version = "~> 0.20"
    }
  }
}

############################
# Kubernetes & Helm
############################

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

############################
# Gitea
############################

# We do NOT reference modules here (Terraform restriction).
# Base URL is deterministic: ClusterIP service in the chosen namespace.
provider "gitea" {
  alias    = "this"
  base_url = "http://gitea-http.${var.gitea_namespace}.svc.cluster.local:3000"
  username = var.gitea_admin_username
  password = var.gitea_admin_password
  insecure = true
}
