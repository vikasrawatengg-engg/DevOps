# 1. THE VPC MODULE
module "my_vpc_layer" {
  source = "./modules/vpc"
}

# 2. THE MISSING SECURITY GROUP BLOCK (Add this!)
resource "aws_security_group" "devops_sg" {
  name        = "vikas-devops-sg"
  description = "Allow SSH traffic"
  vpc_id      = module.my_vpc_layer.vpc_id # Links to your module's VPC output

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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

# 3. JENKINS SERVER
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-09ed39e30153c3bf9"
  instance_type          = "t3.micro"
  subnet_id              = module.my_vpc_layer.subnet_id
  vpc_security_group_ids = [aws_security_group.devops_sg.id] # Now this reference works!

  tags = { Name = "Jenkins-Automation-Server" }
}

# 4. ANSIBLE SERVER
resource "aws_instance" "ansible_server" {
  ami                    = "ami-09ed39e30153c3bf9"
  instance_type          = "t3.micro"
  subnet_id              = module.my_vpc_layer.subnet_id
  vpc_security_group_ids = [aws_security_group.devops_sg.id] # Now this reference works!

  tags = { Name = "Ansible-Controller" }
}