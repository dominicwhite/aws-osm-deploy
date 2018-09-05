provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "openaq" {
  name = "openaq_rds_sg"
  description = "Allow all inbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"
  revoke_rules_on_delete = true
  
  ingress {
    from_port = 0
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.cidr_blocks}"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags {
    Name = "Postgres GIS security group"
  }
}

resource "aws_instance" "default" {
  ami = "ami-04169656fea786776"
  instance_type = "t2.micro"
  key_name = "${var.ec2_key_pair}"
  security_groups = ["${aws_security_group.openaq.name}"]
}

resource "aws_ebs_volume" "example-volume" {
  availability_zone = "${aws_instance.default.availability_zone}"
  type              = "gp2"
  size              = 10
}

resource "aws_volume_attachment" "example-volume-attachment" {
  device_name = "/dev/xvdb"
  instance_id = "${aws_instance.default.id}"
  volume_id   = "${aws_ebs_volume.example-volume.id}"
}
