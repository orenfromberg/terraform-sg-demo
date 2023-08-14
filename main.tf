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

locals {
  allowed_https_cidrs = [
    for cidr_ip in var.https_cidrs : {
      cidr     = cidr_ip,
      port     = 443,
      protocol = "tcp",
      desc     = "an allowed HTTPS CIDR"
  }]

  allowed_https_ips = [
    for nat_ip in var.https_ips : {
      cidr     = format("%s/32", nat_ip),
      port     = 443,
      protocol = "tcp",
      desc     = "an allowed HTTPS IP"
    }
  ]

}

module "security_group" {
  source = "./old_sg_module"
  # source        = "./new_sg_module"
  resource_name = "demo security group"
  vpc_id        = var.vpc_id
  allowed_cidrs = concat(local.allowed_https_cidrs, local.allowed_https_ips)
}

resource "aws_security_group_rule" "standalone_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  description       = "standalone security group rule"
  self              = true
  security_group_id = module.security_group.sg.id
}