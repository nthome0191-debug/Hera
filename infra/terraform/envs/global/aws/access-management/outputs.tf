output "ebs_csi_driver_role_arn" {
  value = module.aws_cluster.ebs_csi_driver_role_arn
}

output "cluster_autoscaler_role_arn" {
  value = module.aws_cluster.cluster_autoscaler_role_arn
}