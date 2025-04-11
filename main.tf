terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  access_key = "AWS_ACCESS_KEY_ID"
  secret_key = "AWS_SECRET_ACCESS_KEY"
}

resource "aws_instance" "example_server" {
  ami           = "ami-0907008e2c2a9e429"
  instance_type = "t3.micro"

  tags = {
    Name = "First instance"
  }
}