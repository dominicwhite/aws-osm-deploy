variable "my_ip" {
  description = "IP for security group CIDR"
}

variable "access_key" {}
variable "secret_key" {}

variable "ec2_key_pair" {
  description = "Name of the key-pair for ec2 SSH"
}

variable "ssh_key_private" {}

variable "rds_password" {}
