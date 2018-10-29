provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "uc1_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "vpc_${var.append_tag}"
  }
}

resource "aws_default_security_group" "uc1_dsg" {
  vpc_id = "${aws_vpc.uc1_vpc.id}"

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "8080"
    to_port     = "8080"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "22"
    to_port     = "22"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "8081"
    to_port     = "8081"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "9292"
    to_port     = "9292"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "8500"
    to_port     = "8500"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "3000"
    to_port     = "3000"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "TCP"
    self        = false
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "uc1_subnet1" {
  vpc_id                  = "${aws_vpc.uc1_vpc.id}"
  cidr_block              = "${var.subnet_cidr1}"
  availability_zone       = "${var.az_1}"
  map_public_ip_on_launch = true

  tags {
    Name = "subnet_${var.append_tag}"
  }
}

resource "aws_internet_gateway" "uc1_igw" {
  vpc_id = "${aws_vpc.uc1_vpc.id}"

  tags {
    Name = "${var.append_tag}"
  }
}

resource "aws_default_route_table" "uc1_rt" {
  depends_on             = ["aws_vpc.uc1_vpc", "aws_internet_gateway.uc1_igw"]
  default_route_table_id = "${aws_vpc.uc1_vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.uc1_igw.id}"
  }

  tags {
    Name = "rt_${var.append_tag}"
  }
}

resource "aws_instance" "uc1_ec2" {
  depends_on      = ["aws_vpc.uc1_vpc", "aws_subnet.uc1_subnet1"]
  count           = "${var.count_var}"
  ami             = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  subnet_id       = "${aws_subnet.uc1_subnet1.id}"
  user_data       = "${file("scripts/userdata.sh")}"
  security_groups = ["${aws_default_security_group.uc1_dsg.id}"]
  key_name        = "playground-key"

  tags {
    Name = "ec2_${var.append_tag}_${count.index}"
  }
}

resource "aws_key_pair" "uc1_kp" {
    key_name   = "playground-key"
    public_key = "${file("~/.ssh/${var.public_ssh_key}")}"
}