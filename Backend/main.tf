variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "iam_user" {
    type    = string
}

variable "bucket_name" {
    type    = string
}

variable "table_name" {
    type    = string
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_iam_user" "this" {
  user_name = var.iam_user
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
  force_destroy = true  
  acl           = "private"

  versioning {
    enabled = true
  } 
  
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "SpecificBucket",
        "Effect": "Allow",
        "Principal": {
          "AWS": "${data.aws_iam_user.this.arn}"    
        },
        "Action": "s3:*",
        "Resource": "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
}
EOF    
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket    = aws_s3_bucket.this.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}

resource "aws_dynamodb_table" "this" {
  name = var.table_name

  read_capacity     = 5
  write_capacity    = 5
  hash_key          = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_iam_user_policy" "this" {
  name = "Terraform"
  user = data.aws_iam_user.this.user_name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "SpecificTable",
        "Effect": "Allow",
        "Action": ["dynamodb:*"],
        "Resource": "arn:aws:dynamodb:*:*:table/${var.table_name}"
      }
    ]
}
EOF
}