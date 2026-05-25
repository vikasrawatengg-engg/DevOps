provider "aws" {
  region = "ap-south-1"
}
terraform {
backend "s3" {
  region = "us-east-1"
  bucket = "vikas-terraform-state-1991"
  key    = "terraform.tfstate"
}
}
# ADD THIS BACK TEMPORARILY SO TERRAFORM CAN REACH OHIO TO DELETE IT
provider "aws" {
  region = "us-east-2"
  alias  = "ohio"
}