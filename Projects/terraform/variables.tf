variable "aws_region" {
  type    = string
  default = "ap-south-1" # Locked to allowed Mumbai region
}

variable "instance_type_micro" {
  type    = string
  default = "t3.micro" # Strictly adheres to allowed micro class limits
}

variable "key_name" {
  type        = string
  description = "Name of your existing AWS SSH Key Pair"
}