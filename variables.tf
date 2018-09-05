variable "cidr_blocks" {
  default = "0.0.0.0/0"
  description = "CIDR for sg"
}

variable "access_key" {}
variable "secret_key" {}

variable "ec2_key_pair" {
  description = "Name of the key-pair for ec2 SSH"
}
