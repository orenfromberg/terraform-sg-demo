resource "aws_security_group" "sg" {
  name        = "the security group"
  description = var.resource_name
  vpc_id      = var.vpc_id
  tags = {
    Application = "demo"
  }


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
}

# resource "aws_security_group_rule" "outbound" {
#   type        = "egress"
#   description = "Allow all outbound traffic"
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.sg.id
# }

