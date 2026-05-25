# ==========================================
# 4. OUTPUT BLOCKS (Assignment 4)
# Capturing and displaying infrastructure properties
# ==========================================

output "database_endpoint" {
  description = "The connection endpoint string for your application configuration"
  value       = aws_db_instance.mysql_db.endpoint
}

output "database_arn" {
  description = "The Amazon Resource Name tracking ID of the RDS system"
  value       = aws_db_instance.mysql_db.arn
}