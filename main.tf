terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" {}
variable "common_tags" {}
variable "allowed_ips_from_aws" {
  description = "allowed IPs from AWS"
  type        = list(string)
  default     = ["172.31.1.15/32", "172.31.1.16/32"]
}
variable "nat_gw_eips" {
  description = "NATGW eips"
  type        = list(string)
  default     = ["172.31.1.1"]
}

locals {
  aws_ips_https = [
    for cidr_ip in var.allowed_ips_from_aws : {
      "cidr"     = cidr_ip,
      "port"     = 443,
      "protocol" = "tcp",
      "desc"     = "aws"
  }]

  nat_cidr_https = [
    for nat_ip in var.nat_gw_eips : {
      cidr     = format("%s/32", nat_ip),
      port     = 443,
      protocol = "tcp",
      desc     = "natgateway"
    }
  ]

}

module "external_alb_sg" {
  source = "./old_sg_module"
  # source = "./new_sg_module"
  resource_name = "LoadBalancerSecurityGroup"
  vpc_id        = var.vpc_id
  allowed_cidrs = concat(local.aws_ips_https, local.nat_cidr_https)
  common_tags   = var.common_tags
}

output "external_alb_sg" {
  value = module.external_alb_sg.sg
}

resource "aws_security_group_rule" "standalone_rule" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  description              = "standalone security group rule"
  self = true
  security_group_id        = module.external_alb_sg.sg.id
}