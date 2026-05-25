# vpc.tf

# THIS DECLARS THE MODULE SO SECURITY GROUPS CAN REFER TO IT
module "my_vpc_layer" {
  source = "./modules/vpc"
}
# ==========================================================
# 1. N. VIRGINIA VPC LAYER (Uses Default Provider)
# ==========================================================
resource "aws_vpc" "virginia_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "virginia-network"
  }
}

resource "aws_subnet" "virginia_subnet" {
  vpc_id                  = aws_vpc.virginia_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "virginia-public-subnet"
  }
}

# ==========================================================
# 2. OHIO VPC LAYER (Explicitly Routed via Alias Provider)
# ==========================================================
resource "aws_vpc" "ohio_vpc" {
  provider             = aws.ohio # Targets Ohio Region Pipeline
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "ohio-network"
  }
}

resource "aws_subnet" "ohio_subnet" {
  provider                = aws.ohio # Targets Ohio Region Pipeline
  vpc_id                  = aws_vpc.ohio_vpc.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ohio-public-subnet"
  }
}