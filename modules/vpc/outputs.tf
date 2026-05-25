# modules/vpc/outputs.tf

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

# Add this new output:
output "subnet_id_b" {
  value = aws_subnet.public_subnet_b.id
}

output "vpc_id" {
  value = aws_vpc.custom_network.id
}