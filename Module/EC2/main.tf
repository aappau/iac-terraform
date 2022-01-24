resource "aws_elb" "this" {
  name            = "${var.env}-web"
  subnets         = var.subnets
  security_groups = var.elb_security_groups

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name      = "${var.env}-web"
	Terraform = "true"
  }
}

resource "aws_launch_template" "this" {
  name                    = "${var.env}-web"
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name 			      = var.ssh_key_name
  vpc_security_group_ids  = var.ec2_security_groups

  tags = {
    Name      = "${var.env}-web"
	Terraform = "true"
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true 
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name  = aws_autoscaling_group.this.id
  elb                     = aws_elb.this.id
}