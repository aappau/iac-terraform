terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  
  backend "s3" {
    bucket          = "appaua-tfbackend"
    dynamodb_table  = "terraform-lock"
    key             = "terraform"
    region          = "us-east-1"
  } 
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

module "Network" {
  source = "../Module/Network"

  vpc_cidrs     = var.vpc_cidrs
  subnet_cidrs  = var.subnet_cidrs
  env           = var.env
}

module "SecurityGroup" {
  source = "../Module/SecurityGroup"
  
  vpc_id          = module.Network.vpc1_id
  ssh_whitelist   = var.ssh_whitelist
  http_whitelist  = var.http_whitelist
}

module "EC2" {
  source = "../Module/EC2"
  
  image_id            = var.image_id 
  instance_type       = var.instance_type
  ssh_key_name        = var.ssh_key_name
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  subnets             = [module.Network.subnet1_id, module.Network.subnet2_id] 
  elb_security_groups = [module.SecurityGroup.elb_sg_id]
  ec2_security_groups = [module.SecurityGroup.ec2_sg_id]
  env                 = var.env
}