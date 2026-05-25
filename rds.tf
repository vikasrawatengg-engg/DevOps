/*# ==========================================================
# 1. RDS SUBNET GROUP (Wired to your Code-Created VPC)
# ==========================================================
resource "aws_db_subnet_group" "rds_subnets" {
  name        = "vikas-modular-rds-subnet-group"
  description = "Database subnet group using my code-created modular subnets"
  
  # Grabbing both subnets directly from your network module layer outputs
  subnet_ids  = [
    module.my_vpc_layer.subnet_id,  # Points to public_subnet in ap-south-1a
    module.my_vpc_layer.subnet_id_b # Points to public_subnet_b in ap-south-1b
  ]

  tags = {
    Name        = "Vikas-Modular-RDS-Subnet-Group"
    Environment = "Dev"
  }
}

# ==========================================================
# 2. RDS DATABASE INSTANCE
# ==========================================================
resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t4g.micro" # Cost-effective Graviton instance
  db_name              = "my_modular_db"
  username             = "admin"
  password             = "SuperSecurePass123!" # Replace with an environment variable later
  
  # Attaching the subnet group we created right above
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
  skip_final_snapshot  = true
  publicly_accessible  = false

  tags = {
    Name        = "Vikas-Modular-MySQL-Server"
    Environment = "Dev"
  }
}
*/