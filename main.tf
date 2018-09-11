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
  description = "Allow inbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"
  revoke_rules_on_delete = true
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.my_ip}/32"]
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
  
  provisioner "local-exec" {
    command = "echo ${aws_instance.default.public_ip} > inventory"
  }
}

resource "aws_ebs_volume" "postgres-volume" {
  availability_zone = "${aws_instance.default.availability_zone}"
  type              = "gp2"
  size              = 10
}

resource "aws_volume_attachment" "postgres-volume-attachment" {
  device_name = "/dev/xvdb"
  instance_id = "${aws_instance.default.id}"
  volume_id   = "${aws_ebs_volume.postgres-volume.id}"
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
    security_groups = ["${aws_security_group.openaq.id}"]
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

/*
data "aws_db_snapshot" "db_snapshot" {
    most_recent = true
    db_instance_identifier = "openaq-postgres-gis"
}
*/

resource "aws_db_instance" "default" {
  identifier = "openaq-postgres-gis"
  allocated_storage = "20"
  engine = "postgres"
  engine_version = "9.6.6"
  instance_class = "db.t2.micro"
  name = "gis"
  username = "gisuser"
  password = "${var.rds_password}"
  port = 5432
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  # snapshot_identifier = "${data.aws_db_snapshot.db_snapshot.id}"
  skip_final_snapshot = false
}

/*
resource "null_resource" "configure_ec2" {
  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i inventory --private-key ${var.ssh_key_private} provision.yml"
  }
  depends_on = ["aws_volume_attachment.postgres-volume-attachment"]
}
*/
