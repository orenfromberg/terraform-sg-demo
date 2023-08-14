variable "vpc_id" {}
variable "https_cidrs" {
  description = "allowed IPs from AWS"
  type        = list(string)
  default     = ["172.31.1.15/32", "172.31.1.16/32"]
}
variable "https_ips" {
  description = "NATGW eips"
  type        = list(string)
  default     = ["172.31.1.1"]
}
