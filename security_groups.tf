/*
Module: ECS-Fargate-ServiceConnect
Version: 1.0.0

This file will create:
  - security groups to attach to ecs tasks and allow permission from private or public subnet.
*/

// traffic to the ECS cluster should only come from the LB
resource "aws_security_group" "ecs_tasks" {
  // add name
  name = "${var.prefix}-${var.env}-${var.app_name}-ecs-tasks-security-group"
  // add description
  description = "Allow inbound from load balancer"
  // set vpc_id
  vpc_id = var.vpc.vpc_id

  // incoming tcp port open for fargate services
  ingress {
    description = "enable incomming traffic to ecs fargate services."
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = var.vpc.public_subnets_cidr_blocks
  }


  dynamic "ingress" {
    for_each = var.extra_ports
    content {
      description = "enable incomming traffic to ecs fargate services."
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = var.vpc.public_subnets_cidr_blocks
    }
  }

  egress {
    description = "by default only vpc cidr is set"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    # false positive tfsec alert
    cidr_blocks = length(var.egress_cidr_blocks) != 0 ? var.egress_cidr_blocks : [var.vpc.vpc_cidr_block]  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }

  dynamic "egress" { #tfsec:ignore:aws-ec2-no-public-egress-sgr
    for_each = [length(var.sg_prefixs)]
    content {
      description     = "to vpc endpoint prefixs"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      prefix_list_ids = var.sg_prefixs
    }
  }

  // add tags
  tags = var.tags
}