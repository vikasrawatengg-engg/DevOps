resource "aws_security_group" "devops_sg" {
  name        = "vikas-apache-automation-sg"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = module.my_vpc_layer.vpc_id

  ingress {
    description = "SSH Management"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Apache Web Traffic"
    from_port   = 80
    to_port     = 80
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