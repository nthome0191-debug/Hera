output "bucket_name" {
  value = var.bucket_name
}

output "lock_table_name" {
  value = var.lock_table_name
}

output "admin_role_arn" {
  value = var.create_admin_role ? aws_iam_role.admin_role[0].arn : null
}
