# ==========================================
# 1. DATA BLOCKS (Assignment 3 - Targeted)
# Fetching your specific active VPC details directly
# ==========================================
data "aws_vpc" "custom" {
  id = "vpc-0c6531873c1c5c774"
}

# Automatically discovers all subnets tied to your specific VPC
data "aws_subnets" "custom" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom.id]
  }
}

# ==========================================
# 2. RDS SUBNET GROUP
# Swapped to use your custom subnet IDs discovered above
# ==========================================
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "vikas-rds-subnet-group"
  subnet_ids = data.aws_subnets.custom.ids

  tags = {
    Name = "My Custom RDS Subnet Group"
  }
}

# ==========================================
# 3. RDS DATABASE INSTANCE (Assignment 2)
# ==========================================
resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20                     
  engine               = "mysql"                
  engine_version       = "8.0"                  
  instance_class       = "db.t4g.micro"         # Cost-effective choice
  db_name              = "my_beginner_db"       
  username             = "admin"                
  password             = "SuperSecurePass123!"  
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
  skip_final_snapshot  = true                   
  publicly_accessible  = false                  

  tags = {
    Name        = "Vikas-MySQL-Server"
    Environment = "Dev"
  }
}