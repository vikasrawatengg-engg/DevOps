output "controller_public_ip" {
  value = aws_instance.controller.public_ip
}

output "kubernetes_master_public_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "kubernetes_worker_1_public_ip" {
  value = aws_instance.k8s_worker1.public_ip
}

output "kubernetes_worker_2_public_ip" {
  value = aws_instance.k8s_worker2.public_ip
}