# ==============================================================================
# SECURITY CLUSTER ARCHITECTURE
# ==============================================================================

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
    cidr_blocks = ["0.0.0.0/0"]
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

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.controller_sg.id]
  }

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

# Fetch Native Ubuntu 22.04 LTS AMI
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


# ==============================================================================
# COMPUTE LAYER BLOCK WITH USER-DATA BOOTSTRAPPING
# ==============================================================================

# Machine 1: Controller / Jenkins Master
resource "aws_instance" "controller" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_micro
  subnet_id               = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.controller_sg.id]
  key_name                = var.key_name
  disable_api_termination = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # AUTOMATED SEQUENCE FOR CONTROLLER (Java, Jenkins, Git)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install openjdk-17-jdk git -y
              sudo mkdir -p /usr/share/keyrings
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "Controller-Jenkins-Master"
  }
}

# Machine 2: Kubernetes Master
resource "aws_instance" "k8s_master" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_micro
  subnet_id               = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.k8s_sg.id]
  key_name                = var.key_name
  disable_api_termination = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # AUTOMATED SEQUENCE FOR K8S MASTER (Docker, Kubeadm, Runtime)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apt-transport-https ca-certificates curl gnupg docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab
              sudo mkdir -p /etc/apt/keyrings
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
              sudo apt-get update -y
              sudo apt-get install -y kubelet kubeadm kubectl openjdk-17-jdk
              sudo apt-mark hold kubelet kubeadm kubectl
              EOF

  tags = {
    Name = "Kubernetes-Master"
  }
}

# Machine 3: Kubernetes Worker 1
resource "aws_instance" "k8s_worker1" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_micro
  subnet_id               = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.k8s_sg.id]
  key_name                = var.key_name
  disable_api_termination = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # AUTOMATED SEQUENCE FOR WORKER 1 (Docker, Kubeadm, Runtimes)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apt-transport-https ca-certificates curl gnupg docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab
              sudo mkdir -p /etc/apt/keyrings
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
              sudo apt-get update -y
              sudo apt-get install -y kubelet kubeadm kubectl openjdk-17-jdk
              sudo apt-mark hold kubelet kubeadm kubectl
              EOF

  tags = {
    Name = "Kubernetes-Worker-1"
  }
}

# Machine 4: Kubernetes Worker 2
resource "aws_instance" "k8s_worker2" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_micro
  subnet_id               = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.k8s_sg.id]
  key_name                = var.key_name
  disable_api_termination = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # AUTOMATED SEQUENCE FOR WORKER 2 (Docker, Kubeadm, Runtimes)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apt-transport-https ca-certificates curl gnupg docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab
              sudo mkdir -p /etc/apt/keyrings
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
              sudo apt-get update -y
              sudo apt-get install -y kubelet kubeadm kubectl
              sudo apt-mark hold kubelet kubeadm kubectl
              EOF

  tags = {
    Name = "Kubernetes-Worker-2"
  }
}