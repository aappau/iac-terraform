resource "aws_vpc" "vpc1" {
  cidr_block            = var.vpc_cidrs[0]
  enable_dns_hostnames  = true
  
  tags = {
    Name      = "${var.env}"
	  Terraform = "true"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.vpc1.id 
  cidr_block              = var.subnet_cidrs[0]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name      = "${var.env}-1"
	  Terraform = "true"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.vpc1.id 
  cidr_block              = var.subnet_cidrs[1]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name      = "${var.env}-2"
	  Terraform = "true"
  }
}

resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.vpc1.id
  
  tags = {
    Name      = "${var.env}"
    Terraform = "true"
  }
}

resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc1.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }
  	
  tags = {
    Name      = "${var.env}"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "route_subnet1" {
  subnet_id       = aws_subnet.subnet1.id 
  route_table_id  = aws_route_table.route_table1.id
}

resource "aws_route_table_association" "route_subnet2" {
  subnet_id       = aws_subnet.subnet2.id
  route_table_id  = aws_route_table.route_table1.id
}

data "aws_availability_zones" "available" {
  state = "available"
}