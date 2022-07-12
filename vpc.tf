provider "aws" {
region = "ap-south-1"
# access key, secret_key 
}
locals {
staging_env = "staging"
}

resource "aws_vpc" "staging-vpc" {
cidr_block = "10.5.0.0/16"
tags = {
Name = "${local.staging_env}-vpc-tag"
}
}
resource "aws_subnet" "staging-subnet" {
vpc_id = aws_vpc.staging-vpc.id
cidr_block = "10.5.0.0/16"
tags = {
Name = "${local.staging_env}-vpc-tag"
}
}
resource "aws_instance" "ec2_example" {
ami = "ami-08df646e18b182346"
instance_type = "t2.micro"
subnet_id = aws_subnet.staging-subnet.id
tags = {
Name = "${local.staging_env}-Terra-ec2"
}
}
