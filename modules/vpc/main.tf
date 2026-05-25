# modules/vpc/main.tf

resource "aws_vpc" "custom_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "vikas-modular-vpc" }
}

# Ensure the resource label is exactly "public_subnet"
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_network.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "vikas-public-subnet-1a" }
}

# Ensure the resource label is exactly "public_subnet_b"
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.custom_network.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "vikas-public-subnet-1b" }
}

# ==========================================================

# 3. INTERNET GATEWAY (The Door to the Internet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_network.id
  tags   = { Name = "vikas-vpc-igw" }
}

# 4. ROUTE TABLE (The Roadmap directing public traffic to the IGW door)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_network.id

  route {
    cidr_block = "0.0.0.0/0" # Points all external internet traffic to the IGW
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "vikas-public-route-table" }
}

# 5. LINK ROUTE TABLE TO SUBNET A
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. LINK ROUTE TABLE TO SUBNET B
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}