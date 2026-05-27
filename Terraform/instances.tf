# 1. NEW UBUNTU WEB SERVER WITH AUTOMATED SCRIPT
resource "aws_instance" "web_automation_server" {
  ami                    = "ami-007020fd9c84e18c7" # Ubuntu 24.04 LTS in Mumbai (ap-south-1)
  instance_type          = "t3.micro"
  subnet_id              = module.my_vpc_layer.subnet_id
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # Inject and execute the local shell script file at boot time
  user_data = file("${path.module}/install_apache.sh")

  tags = {
    Name        = "Vikas-Apache-Automated-Server"
    Environment = "Dev"
  }
}

# ==========================================================
# EXTRA REQ: EXPORT PUBLIC IP TO A LOCAL WINDOWS FILE
# ==========================================================
resource "local_file" "ip_exporter" {
  content  = "The deployed Apache server public IP is: ${aws_instance.web_automation_server.public_ip}\n"
  filename = "${path.module}/server_ip.txt" # Creates a text file right inside your directory
}
