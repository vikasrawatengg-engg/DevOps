variable "aws_region" {
  type    = string
  default = "ap-south-1" # Mumbai region (or switch to your primary region)
}

variable "instance_type_controller" {
  type    = string
  default = "t3.medium" # Jenkins/Ansible needs breathing room
}

variable "instance_type_k8s" {
  type    = string
  default = "t3.medium" # Kubeadm init requires minimum 2 vCPUs
}

variable "key_name" {
  type        = string
  description = "Name of your existing AWS SSH Key Pair"
}