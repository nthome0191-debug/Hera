terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Kubernetes provider - only configured when cluster_name is provided
provider "kubernetes" {
  host                   = var.cluster_name != "" ? data.aws_eks_cluster.cluster[0].endpoint : "https://localhost"
  cluster_ca_certificate = var.cluster_name != "" ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data) : null
  token                  = var.cluster_name != "" ? data.aws_eks_cluster_auth.cluster[0].token : null
}
