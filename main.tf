provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "rds" {
  name = "openaq_rds_sg"
  description = "Allow all inbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"
  revoke_rules_on_delete = true
  
  ingress {
    from_port = 5432
    to_port = 5432
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

resource "aws_db_instance" "default" {
  identifier = "openaq-postgres-gis"
  allocated_storage = "20"
  engine = "postgres"
  engine_version = "9.6.6"
  instance_class = "db.t2.micro"
  name = "gis"
  username = "gisuser"
  password = "${var.password}"
  port = 5432
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  skip_final_snapshot = true
}


