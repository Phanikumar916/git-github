provider "aws" {
region = "us-east-1"
}

# VPC
resource "aws_vpc" "terra_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
Name = "Terraform_VPC"
}  
}

# Internet Gateway 
resource "aws_internet_gateway" "terr_igw" {
vpc_id = "${aws_vpc.terra_vpc.id}"
tags = {
Name = "main"
}
}

# subnets : public
resource "aws_subnet" "public" {
   count = "${length(var.subnets_cidr)}"
   vpc_id = "${aws_vpc.terra_vpc.id}"
   cidr_block = "${element(var.subnets_cidr,count.index)}"
   availability_zone = "${element(var.azs,count.index)}"
tags = {
Name = "Subnet-${count.index+1}"
}
}

# Route table : attach Internet Gateway
resource "aws_route_table" "public_rt" {
   vpc_id = "${aws_vpc.terra_vpc.id}"
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.terr_igw.id}"
   }
   tags = {
Name = "publicRouteTable"
}
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
    count = "${length(var.subnets_cidr)}"
    subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
    route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_security_group" "webservers" {
    name = "allow_http"
    description = "Allow http inbound traffic"
    vpc_id = "${aws_vpc.terra_vpc.id}
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "ssh from vpc"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "webservers" {
    count = var.number_instances
    ami = var.amiid
    instance_type = var.instance_type
    security_groups = ["${aws_security_group.webservers.id}"]
    subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
    user_date = "${file("install_httpd.sh")}"
    key_name = var.key_name
    tags = {
    Name = "Server-${count.index}"
}
}
Footer
© 2022 GitHub, Inc.
Footer navigation
Terms
Privac
