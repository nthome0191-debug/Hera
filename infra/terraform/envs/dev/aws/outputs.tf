# Development Environment Outputs - AWS

# Network Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.network.vpc_cidr
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.network.nat_gateway_ips
}

output "availability_zones" {
  description = "Availability zones in use"
  value       = module.network.availability_zones
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "cluster_name" {
  description = "EKS cluster name (with random suffix if enabled)"
  value       = module.eks_cluster.cluster_name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = module.eks_cluster.node_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS nodes"
  value       = module.eks_cluster.node_iam_role_arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  value       = module.eks_cluster.oidc_provider_url
}

output "node_group_ids" {
  description = "Map of EKS node group IDs"
  value       = module.eks_cluster.node_group_ids
}

output "node_group_status" {
  description = "Map of EKS node group statuses"
  value       = module.eks_cluster.node_group_status
}

output "kubeconfig" {
  description = "Kubeconfig for cluster access"
  value       = module.eks_cluster.kubeconfig
  sensitive   = true
}

output "eks_addons" {
  description = "Map of EKS addons and their versions"
  value       = module.eks_cluster.eks_addons
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = module.eks_cluster.ebs_csi_driver_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = module.eks_cluster.cluster_autoscaler_role_arn
}

# ============================================
# Platform Layer Outputs
# ============================================

# Gitea Outputs
output "gitea_admin_username" {
  description = "Gitea admin username"
  value       = module.gitea.admin_username
}

output "gitea_admin_password" {
  description = "Gitea admin password"
  value       = module.gitea.admin_password
  sensitive   = true
}

output "gitea_service_url" {
  description = "Gitea in-cluster service URL"
  value       = module.gitea.service_url
}

output "gitea_port_forward" {
  description = "Command to access Gitea UI"
  value       = module.gitea.kubectl_port_forward
}

# ArgoCD Outputs
output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.argocd.admin_password
  sensitive   = true
}

output "argocd_port_forward" {
  description = "Command to access ArgoCD UI"
  value       = module.argocd.kubectl_port_forward
}

# Quick Access Guide
output "platform_access" {
  description = "How to access platform services"
  value       = <<-EOT
    ============================================
    Platform Services Access Guide
    ============================================

    Gitea (In-Cluster Git) - Namespace: git
    - Port-forward: ${module.gitea.kubectl_port_forward}
    - URL: http://localhost:3000
    - Username: ${module.gitea.admin_username}
    - Password: $(terraform output -raw gitea_admin_password)
    - Service URL: ${module.gitea.service_url}

    ArgoCD (GitOps) - Namespace: argocd
    - Port-forward: ${module.argocd.kubectl_port_forward}
    - URL: https://localhost:8080
    - Username: admin
    - Password: $(terraform output -raw argocd_admin_password)

    Next Steps:
    1. Access Gitea and create a repository "gitops-repo"
    2. Push your Kubernetes manifests to Gitea
    3. Uncomment git_repository_* variables in main.tf
    4. Run 'terraform apply' to connect ArgoCD to Gitea
    5. Access ArgoCD and create applications
    6. Watch ArgoCD automatically sync your applications!

    Note: Services are in separate namespaces for isolation.
    They communicate via Kubernetes DNS across namespaces.
  EOT
}
