variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_cidrs" {
  type = list(string)
}

variable "subnet_cidrs" {
  type = list(string)
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