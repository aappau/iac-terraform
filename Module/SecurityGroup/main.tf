resource "aws_security_group" "elb_sg" {
  name         = "web-elb"
  description  = "web elb security group"
  vpc_id 	   = var.vpc_id	

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
  vpc_id 	   = var.vpc_id

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