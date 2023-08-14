resource "aws_security_group" "sg" {
  name        = "the security group"
  description = var.resource_name
  vpc_id      = var.vpc_id
  tags = {
    Application = "demo"
  }
}

resource "aws_security_group_rule" "ipv4_cidrs" {
  for_each = length(var.allowed_cidrs) < 1 ? {} : { for i, ing in var.allowed_cidrs : i => {
    cidr_block = ing.cidr
    port       = tonumber(ing.port)
    desc       = ing.desc
    protocol   = ing.protocol
  } }
  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  cidr_blocks       = [each.value.cidr_block]
  description       = each.value.desc
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "ipv6_cidrs" {
  for_each = length(var.allowed_v6_cidrs) < 1 ? {} : { for i, ing in var.allowed_v6_cidrs : i => {
    ipv6_cidr_block = ing.cidr
    port            = tonumber(ing.port)
    desc            = ing.desc
    protocol        = ing.protocol
  } }
  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  ipv6_cidr_blocks  = [each.value.ipv6_cidr_block]
  description       = each.value.desc
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "allowed_security_groups" {
  for_each = length(var.allowed_sgs) < 1 ? {} : { for i, ing in var.allowed_sgs : i => {
    sg_id    = ing.sg_id
    port     = tonumber(ing.port)
    desc     = ing.desc
    protocol = ing.protocol
  } }
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.sg_id
  description              = each.value.desc
  security_group_id        = aws_security_group.sg.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}
