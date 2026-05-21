provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "abc" {
    bucket = "vikas12341"
}