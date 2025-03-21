/* 
Module: ECS-Fargate-ServiceConnect
Version: 1.0.0

This file will create following:
  - aws ecs fargate cluster
  - ecs task definition
  - ecs service
*/

locals {
  env = concat(var.secrets, var.parameters)
}

// create aws_ecs_cluster with input name
resource "aws_ecs_cluster" "main" {
  // set name for ecs cluster
  name = "${var.prefix}-${var.env}-${var.app_name}-cluster"

  // enable container insights
  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }
  // set tags for cluster
  tags = var.tags
}

// creating secret manager json defined in: ./templates/env_tmp.json.tpl
data "template_file" "env_tmp" {
  // run as many times as secrets in variables
  count = length(local.env)
  // set temp file path
  template = file("${path.module}/templates/env_tmp.json.tpl")
  vars = {
    name = element(local.env.*.name, count.index)
    arn  = element(local.env.*.arn, count.index)
  }
}

// creating port mapping json defined in: ./templates/portmappings_tmp.json.tpl
data "template_file" "portmapping" {
  // run as many times as secrets in variables
  count = length(var.extra_ports)
  // set temp file path
  template = file("${path.module}/templates/portmappings_tmp.json.tpl")
  vars = {
    port = element(var.extra_ports, count.index)
  }
}

// creating xray json defined in: ./templates/xray_tmp.json.tpl
data "template_file" "xray" {
  // set temp file path
  template = file("${path.module}/templates/xray_tmp.json.tpl")
}


// template to run the containers
data "template_file" "service_tmp" {
  // get template file from templates folder
  template = file("${path.module}/templates/service_tmp.json.tpl")
  // variables for template
  vars = {
    // set container image provided by user or ecr url
    app_image = var.app_image == "none" ? aws_ecr_repository.ecr_repo[0].repository_url : var.app_image
    extra_ports         = join("", data.template_file.portmapping.*.rendered)
    app_port            = var.app_port
    fargate_cpu         = var.fargate_cpu
    fargate_memory      = var.fargate_memory
    aws_region          = var.region
    prefix              = var.prefix
    app_name            = var.app_name
    env                 = var.env
    secrets             = join(",", data.template_file.env_tmp.*.rendered)
    xray                = var.xray ? data.template_file.xray.rendered : ""
  }
}

// task definition for fargate cluster
resource "aws_ecs_task_definition" "main" {
  // family name
  family = "${var.prefix}-${var.env}-${var.app_name}-family"
  // render task template to definition
  container_definitions = data.template_file.service_tmp.rendered
  // type of service is fargate
  requires_compatibilities = ["FARGATE"]
  // set network mode to awsvpc
  network_mode = "awsvpc"
  // set cpu for services 
  cpu = var.fargate_cpu
  // set memory for service
  memory = var.fargate_memory

  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
  // attach a role to definition described in role.tf
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  // add tags 
  tags = var.tags
}

// ecs fargate service
resource "aws_ecs_service" "main" {
  // set a name for service
  name = "${var.prefix}-${var.env}-${var.app_name}-service"
  // add service to cluster
  cluster = aws_ecs_cluster.main.id
  // add task definition 
  task_definition = aws_ecs_task_definition.main.id
  // set the desired count
  desired_count = var.min_task_count
  // set launch type
  launch_type = "FARGATE"
  // don't let outsider change task definition.
  lifecycle {
    ignore_changes = [task_definition]
  }
  // set the security groups and don't assign public ip
  network_configuration {
    // set the security group to service defined in security.tf
    // set security group if alb set to true in module variables
    security_groups = [aws_security_group.ecs_tasks.id]
    // service can autoscale in private subnet
    subnets = var.vpc.private_subnets
    // no public ip assigned will use loadbalancer
    assign_public_ip = false
  }
  service_connect_configuration {
    enabled = var.service_connect_enabled
    # log_configuration = {}
    namespace = var.cloudmap_namespace_arn
    service {
      client_alias {port = var.app_port}
      discovery_name = "${var.prefix}-${var.env}-${var.app_name}"// name of cloudmap service
      ingress_port_override = var.sc_ingress_port_override// port number for proxy to listen on 
      port_name =  var.app_name// name of one of portMappings from all containers in th task defintion
      # timeout = // configuration timeout for service connect
      # tls = // config for enabling tls
    }
  }

  // Dynamically create load balancer configuration blocks
  dynamic "load_balancer" {
    for_each = var.target_group_configs
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = "${var.prefix}-${var.env}-${var.app_name}"
      container_port   = var.app_port
    }
  }

  // For backward compatibility, add default target group if provided
  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [var.target_group_arn] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = "${var.prefix}-${var.env}-${var.app_name}"
      container_port   = var.app_port
    }
  }

  // Combine both dependency approaches for backward compatibility
  depends_on = [
    var.lb_listener_rule
  ]
  
  // add tags 
  tags = var.tags
}