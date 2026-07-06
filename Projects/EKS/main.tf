/*# =================================================================
# 1. TERRAFORM CONFIGURATION & PROVIDERS SETUP
# =================================================================
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80" 
    }
  }
}

variable "aws_region" {
  type        = string
  description = "The target AWS Region for all resources"
  default     = "ap-south-1" 
}

# =================================================================
# 2. PROVIDER INITIALIZATION
# =================================================================
provider "aws" {
  region = var.aws_region
}

# =================================================================
# 3. NETWORK INFRASTRUCTURE (VPC & SUBNETS)
# =================================================================
data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "vikas-eks-vpc" }
}

resource "aws_subnet" "eks_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                 = { Name = "vikas-eks-subnet-${count.index}" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "vikas-eks-igw" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  count          = 2
  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.rt.id
}

# =================================================================
# 4. STANDARD EKS CONTROL PLANE (Managed Cluster)
# =================================================================
resource "aws_eks_cluster" "aws_eks" {
  name     = "vikas-eks-cluster-01"
  role_arn = "arn:aws:iam::867637277744:role/EKSClusterServiceRole" 

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  compute_config {
    enabled = false
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false
    }
  }

  storage_config {
    block_storage {
      enabled = false
    }
  }
}

# =================================================================
# 5. SELF-MANAGED COMPUTE WORKERS
# =================================================================
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "vikas-eks-node-"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = "t3.medium"

  network_interfaces {
    associate_public_ip_address = true
  }

  # Clean bootstrap join sequence
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -o xtrace
              /etc/eks/bootstrap.sh vikas-eks-cluster-01
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                          = "vikas-eks-worker"
      "kubernetes.io/cluster/vikas-eks-cluster-01" = "owned"
    }
  }
}

resource "aws_autoscaling_group" "eks_asg" {
  name_prefix         = "vikas-eks-asg-"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = aws_subnet.eks_subnets[*].id

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/vikas-eks-cluster-01"
    value               = "owned"
    propagate_at_launch = true
  }
}
*/