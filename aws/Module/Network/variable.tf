variable "vpc_cidrs" {
  type = list(string)
}

variable "subnet_cidrs" {
  type = list(string)
}

variable "env" {
  type = string
}