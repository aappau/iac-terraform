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

variable "subnets" {
  type = list(string)
}

variable "elb_security_groups" {
  type = list(string)
}

variable "ec2_security_groups" {
  type = list(string)
}

variable "env" {
  type = string
}