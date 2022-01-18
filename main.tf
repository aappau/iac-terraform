terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {}

# Variables
variable "subnet_cidr_blocks" {
	description = "cidr blocks for subnets"
}

# Creates VPC
resource "aws_vpc" "prod_vpc" {
  	cidr_block = "10.0.0.0/16"

  	tags = {
    	Name = "production"
  	}
}

# Creates an Internet Gateway
resource "aws_internet_gateway" "prod_gw" {
  	vpc_id = aws_vpc.prod_vpc.id

  	tags = {
    	Name = "prod-gw"
  	}
}

# Creates a Route Table
resource "aws_route_table" "prod_route_table" {
  	vpc_id = aws_vpc.prod_vpc.id

  	route {
    	cidr_block = "0.0.0.0/0"
    	gateway_id = aws_internet_gateway.prod_gw.id
  	}

  	tags = {
    	Name = "prod"
  	}
}

# Creates a Subnet
resource "aws_subnet" "prod_subnet_1" {
  	vpc_id     = aws_vpc.prod_vpc.id
  	cidr_block = var.subnet_cidr_blocks[0].cidr_block
	availability_zone = "us-east-1a"

  	tags = {
    	Name = var.subnet_cidr_blocks[0].name
  	}
}

# Associates Subnet with Route Table
resource "aws_route_table_association" "a" {
  	subnet_id      = aws_subnet.prod_subnet_1.id
  	route_table_id = aws_route_table.prod_route_table.id
}

# Creates a Security Group
resource "aws_security_group" "web" {
	name        = "web"
	description = "prod VPC security group"
	vpc_id      = aws_vpc.prod_vpc.id

	ingress {
		description      = "HTTPS"
		from_port        = 443
		to_port          = 443
		protocol         = "tcp"
		cidr_blocks      = ["0.0.0.0/0"]
	}

	ingress {
		description      = "HTTP"
		from_port        = 80
		to_port          = 80
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
		cidr_blocks      = ["0.0.0.0/0"]
	}

	tags = {
		Name = "prod_web_sg"
	}
}

# Creates a Network Interface with an IP in the subnet that is created
resource "aws_network_interface" "web_server_nic" {
	subnet_id       = aws_subnet.prod_subnet_1.id
	private_ips     = ["10.0.1.50"]
	security_groups = [aws_security_group.web.id]
}

# Assigns an Elastic IP to the Network Interface created
resource "aws_eip" "one" {
  	vpc                       	= true
  	network_interface         	= aws_network_interface.web_server_nic.id
  	associate_with_private_ip 	= "10.0.1.50"
	depends_on 				 	= [aws_internet_gateway.prod_gw]
	
}

# Creates an Amazon Linux 2 VM and install Apache Web Server
resource "aws_instance" "web_server" {
    ami           		= "ami-08e4e35cccc6189f4"
    instance_type 		= "t2.micro"
	availability_zone 	= "us-east-1a"
	key_name 			= "terraform"

	network_interface {
	  	device_index 	= 0
		network_interface_id = aws_network_interface.web_server_nic.id  
	}

	user_data = <<-EOF
				#!/bin/bash
				sudo yum update -y
				sudo yum install -y httpd
				sudo systemctl start httpd
				sudo systemctl enable httpd
				sudo bash -c 'echo Server ready for production! > /var/www/html/index.html'
				EOF

    tags = {
        Name = "prod-web-server"
	}
}

# Outputs
output "server_public_ip" {
	value = aws_eip.one.public_ip
}

output "server_private_ip" {
	value = aws_instance.web_server.private_ip
}