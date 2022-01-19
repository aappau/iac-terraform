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

variable "prod_ssh_whitelist" {
  type = list(string)
}

variable "prod_http_whitelist" {
  type = list(string)
}

variable "prod_image_id" {
  type = string
}

variable "prod_instance_type" {
  type = string
}

variable "prod_ssh_key_name" {
  type = string
}

variable "prod_desired_capacity" {
  type = number
}

variable "prod_max_size" {
  type = number
}

variable "prod_min_size" {
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
  name         = "prod-elb"
  description  = "prod elb security group"

  ingress {
	  description       = "HTTP"
	  from_port         = 80
	  to_port           = 80
	  protocol          = "tcp"
	  cidr_blocks       = var.prod_http_whitelist
  }
  ingress {
	  description       = "HTTPS"
	  from_port         = 443
	  to_port           = 443
	  protocol          = "tcp"
	  cidr_blocks       = var.prod_http_whitelist
  }
  egress {
	  from_port         = 0
	  to_port           = 0
	  protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "prod-elb"
	  Terraform = "true"
  }
}

resource "aws_security_group" "instances_sg" {
  name         = "prod-web"
  description  = "prod web security group"

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
	  cidr_blocks       = var.prod_ssh_whitelist
  }
  egress {
	  from_port         = 0
	  to_port           = 0
	  protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "prod-instances"
	  Terraform = "true"
  }
}

resource "aws_elb" "prod" {
  name            = "prod-web"
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name      = "prod-web"
	  Terraform = "true"
  }
}

resource "aws_launch_template" "prod" {
  name                    = "prod-web"
  image_id                = var.prod_image_id
  instance_type           = var.prod_instance_type
  key_name 			          = var.prod_ssh_key_name
  vpc_security_group_ids  = [aws_security_group.instances_sg.id]
}

resource "aws_autoscaling_group" "prod" {
  desired_capacity    = var.prod_desired_capacity
  max_size            = var.prod_max_size
  min_size            = var.prod_min_size
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  launch_template {
    id      = aws_launch_template.prod.id
    version = aws_launch_template.prod.latest_version
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true 
  }
}

resource "aws_autoscaling_attachment" "prod" {
  autoscaling_group_name  = aws_autoscaling_group.prod.id
  elb                     = aws_elb.prod.id
}