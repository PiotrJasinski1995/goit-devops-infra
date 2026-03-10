output "endpoint" {
  description = "Database endpoint"
  value = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.this.id
}