# Provider Configuration - AWS Dev Environment

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
    # Uncomment when implementing platform modules
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2.23"
    # }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "~> 2.11"
    # }
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
