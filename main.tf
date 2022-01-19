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

variable "ssh_whitelist" {
  type = list(string)
}

variable "http_whitelist" {
  type = list(string)
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Terraform = "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1b"

  tags = {
    Terraform = "true"
  }
}

resource "aws_security_group" "elb_sg" {
  name         = "web-elb"
  description  = "web elb security group"

  ingress {
	  description       = "HTTP"
	  from_port         = 80
	  to_port           = 80
	  protocol          = "tcp"
	  cidr_blocks       = var.http_whitelist
  }
  ingress {
	  description       = "HTTPS"
	  from_port         = 443
	  to_port           = 443
	  protocol          = "tcp"
	  cidr_blocks       = var.http_whitelist
  }
  egress {
	  from_port         = 0
	  to_port           = 0
	  protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "web-elb"
	  Terraform = "true"
  }
}

resource "aws_security_group" "instances_sg" {
  name         = "web-instances"
  description  = "web instances security group"

  ingress {
	  description       = "HTTP"
	  from_port         = 80
	  to_port           = 80
	  protocol          = "tcp"
	  security_groups   = [aws_security_group.elb_sg.id]
  }
  ingress {
	  description       = "HTTPS"
	  from_port         = 443
	  to_port           = 443
	  protocol          = "tcp"
	  security_groups   = [aws_security_group.elb_sg.id]
  }
  ingress {
	  description       = "SSH"
	  from_port         = 22
	  to_port           = 22
	  protocol          = "tcp"
	  cidr_blocks       = var.ssh_whitelist
  }
  egress {
	  from_port         = 0
	  to_port           = 0
	  protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "web-instances"
	  Terraform = "true"
  }
}

module "web_app" {
  source = "./modules/web_app"
  
  image_id            = var.image_id 
  instance_type       = var.instance_type
  ssh_key_name        = var.ssh_key_name
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  subnets             = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id] 
  elb_security_groups = [aws_security_group.elb_sg.id]
  ec2_security_groups = [aws_security_group.instances_sg.id]
  env                 = "prod"
}