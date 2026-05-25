output "vpc_id" {
  value = aws_vpc.custom_network.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "subnet_id_b" {
  value = aws_subnet.public_subnet_b.id
}