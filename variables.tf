variable "cidr_blocks" {
  default = "0.0.0.0/0"
  description = "CIDR for sg"
}

variable "password" {
  description = "Database password"
}
