variable "vpc_id" {
  type = string
}

variable "ssh_whitelist" {
  type = list(string)
}

variable "http_whitelist" {
  type = list(string)
}