terraform {
  required_version = ">= 1.6.0"

  required_providers {
    gitea = {
      source  = "go-gitea/gitea"
      version = "~> 0.20"
    }
  }
}
