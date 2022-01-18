terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# adoptes default VPC
resource "aws_default_vpc" "default" {}

# creates a Security group
resource "aws_security_group" "prod_web" {
  name         = "prod-web"
  description  = "prod web security group"

  ingress {
	description      = "HTTP"
	from_port        = 80
	to_port          = 80
	protocol         = "tcp"
	cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
	description      = "HTTPS"
	from_port        = 443
	to_port          = 443
	protocol         = "tcp"
	cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
	description      = "SSH"
	from_port        = 22
	to_port          = 22
	protocol         = "tcp"
	cidr_blocks      = ["67.162.254.33/32"]
  }
  egress {
	from_port        = 0
	to_port          = 0
	protocol         = "-1"
    cidr_blocks    = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "prod-web"
	  Terraform = "true"
  }
}

# creates an EC2 instance
resource "aws_instance" "prod_web" {
  ami           		= "ami-08e4e35cccc6189f4"
  instance_type 		= "t2.micro"
	availability_zone = "us-east-1a"
	key_name 			    = "terraform"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  user_data = <<-EOF
				#!/bin/bash
				sudo yum update -y
				sudo yum install -y httpd
				sudo systemctl start httpd
				sudo systemctl enable httpd
				sudo bash -c 'echo Server ready for production! > /var/www/html/index.html'
				EOF
  
  tags = {
    Name      = "prod-web"
    Terraform = "true"
  }  
}

# creates an elastic IP
resource "aws_eip" "prod_web" {
  instance = aws_instance.prod_web.id 

  tags = {
    Name      = "prod-web"
	  Terraform = "true"
  }
}