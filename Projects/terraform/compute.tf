# Security Group for Controller Node
resource "aws_security_group" "controller_sg" {
  name        = "controller-sg"
  description = "Allow SSH and Jenkins access"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins Web UI access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Kubernetes Cluster Nodes
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Allow internal K8s traffic and external NodePort"
  vpc_id      = aws_vpc.prod_vpc.id

  # Internal cluster traffic (Full communication within security group)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K8s API Server Access from Controller
  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.controller_sg.id]
  }

  # Target Capstone NodePort Assignment 
  ingress {
    from_port   = 30008
    to_port     = 30008
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source to fetch latest Ubuntu 22.04 LTS AMI natively
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Machine 1: Controller / Jenkins Master
resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_controller
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.controller_sg.id]
  key_name               = var.key_name
  tags = {
    Name = "Controller-Jenkins-Master"
  }
}

# Machine 2: Kubernetes Master
resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_k8s
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name
  tags = {
    Name = "Kubernetes-Master"
  }
}

# Machine 3: Kubernetes Worker 1
resource "aws_instance" "k8s_worker1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_k8s
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name
  tags = {
    Name = "Kubernetes-Worker-1"
  }
}

# Machine 4: Kubernetes Worker 2
resource "aws_instance" "k8s_worker2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_k8s
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name
  tags = {
    Name = "Kubernetes-Worker-2"
  }
}