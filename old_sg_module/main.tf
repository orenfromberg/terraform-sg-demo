variable "common_tags" {}
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

resource "aws_security_group" "sg" {
  name        = "${var.common_tags.ClusterName}-${var.resource_name}"
  description = var.resource_name
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_cidrs) < 1 ? [] : [for ing in var.allowed_cidrs : {
      cidr_block = ing.cidr
      port       = tonumber(ing.port)
      desc       = ing.desc
      protocol   = ing.protocol
    }]

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr_block]
      description = ingress.value.desc
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_v6_cidrs) < 1 ? [] : [for ing in var.allowed_v6_cidrs : {
      ipv6_cidr_block = ing.cidr
      port            = tonumber(ing.port)
      desc            = ing.desc
      protocol        = ing.protocol
    }]

    content {
      from_port        = ingress.value.port
      to_port          = ingress.value.port
      protocol         = ingress.value.protocol
      ipv6_cidr_blocks = [ingress.value.ipv6_cidr_block]
      description      = ingress.value.desc
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_sgs) < 1 ? [] : [for ing in var.allowed_sgs : {
      sg_id    = ing.sg_id
      port     = tonumber(ing.port)
      desc     = ing.desc
      protocol = ing.protocol
    }]

    content {
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = ingress.value.protocol
      security_groups = [ingress.value.sg_id]
      description     = ingress.value.desc
    }
  }

  tags = merge(
    var.common_tags,
    tomap({
      Name = "${var.common_tags.ClusterName}-${var.resource_name}" }
    )
  )
}

resource "aws_security_group_rule" "outbound" {
  type        = "egress"
  description = "Allow all outbound traffic"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  # We are allowing all outbound for the program
  #tfsec:ignore:aws-vpc-no-public-egress-sgr
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

output "sg" {
  value = aws_security_group.sg
}
