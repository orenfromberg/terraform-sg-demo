variable "resource_name" {}

variable "vpc_id" {}

variable "allowed_cidrs" {
  type    = list(map(string))
  default = []
}
variable "allowed_sgs" {
  type    = list(map(string))
  default = []
}
variable "public_cidr_block" {
  default = "0.0.0.0/0"
}

variable "allowed_v6_cidrs" {
  type    = list(map(string))
  default = []
}
