output "elb_sg_id" {
    value = aws_security_group.elb_sg.id
}

output "ec2_sg_id" {
    value = aws_security_group.instances_sg.id
}