output "karpenter_controller_role_arn" {
  description = "IAM Role ARN for the Karpenter controller"
  value       = module.karpenter_controller_role.iam_role_arn
}

output "karpenter_node_role_name" {
  description = "The name of the IAM role for nodes launched by Karpenter"
  value       = aws_iam_role.karpenter_node_role.name
}

output "interruption_queue_name" {
  description = "The name of the SQS queue used for interruption handling"
  value       = aws_sqs_queue.karpenter_interruption.name
}