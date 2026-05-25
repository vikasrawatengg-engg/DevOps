# modules/vpc/main.tf

# Create a Custom Network
resource "aws_vpc" "custom_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vikas-modular-vpc"
  }
}

# Create a Public Subnet inside that network
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_network.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "vikas-public-subnet-1a"
  }
}

# Add this new second subnet block:
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.custom_network.id
  cidr_block              = "10.0.2.0/24"          # Unique CIDR block
  availability_zone       = "ap-south-1b"          # Different Availability Zone!
  map_public_ip_on_launch = true

  tags = {
    Name = "vikas-public-subnet-1b"
  }
}