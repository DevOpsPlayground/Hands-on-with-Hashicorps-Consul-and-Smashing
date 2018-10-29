variable "aws_region" {
  default = "ap-southeast-1"
}

# This tag will be appended to all AWS resources
variable "append_tag" {
  default = "PLAYGROUND"
}

variable "count_var" { 
  description = "Number of servers to create"
}

variable "vpc_cidr" {
  default = "10.31.0.0/16"
}

variable "subnet_cidr1" {
  default = "10.31.10.0/24"
}

variable "az_1" {
  default = "ap-southeast-1a"
}

# Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type
variable "ami_id" {
  default = "ami-08569b978cc4dfa10"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "public_ssh_key" { }