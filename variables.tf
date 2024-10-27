/*
Module: ECS-Fargate-ServiceConnect
Version: 1.0.0

This file defines all the variables for this module.
Variables are divided into two sections:
  - Required variables
  - Optional variables
*/

//  -------------Module Variables(Required)---------------
// project variables
variable "region" {
  type        = string
  description = "region where to create resources"
}

variable "env" {
  type        = string
  description = "app deployment environment"
}

// app variables
variable "app_name" {
  type        = string
  description = "application name"
}

variable "app_port" {
  type        = string
  description = "app port to expose"
}

variable "cw_dashboard" {
  type        = string
  description = "set to true to add cloudwatch dashboard"
  default     = "none"
}

variable "container_insights" {
  type        = bool
  description = "enable or disable container insights"
  default     = true
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "cidr for out going traffic from ecs services. By-default vpc cidr is set"
  default     = []
}

variable "log_retention_in_days" {
  type        = number
  description = "log retention logs in days"
  default     = 90
}

// vpc variables
variable "vpc" {
  description = "vpc id to create resources"
}

variable "sg_prefixs" {
  type        = list(string)
  description = "vpc endpoint prefixs to be added to sg"
  default     = []
}


// encryption keys vars
variable "ecr_kms_key_arn" {
  type        = string
  description = "provide ecr kms key for customer encryption"
  default     = "" // by default it will use aws default keys
}

variable "cloudwatch_kms_key_arn" {
  type        = string
  description = "provide cloud watch kms key for customer encryption"
  default     = "" // by default it will use aws default keys
}

// lb vars
variable "lb_access_logs_s3_bucket" {
  type        = string
  description = "s3 name to store lb vars"
  default     = ""
}

variable "enable_cross_zone_load_balancing" {
  type        =  bool
  description = "enable cross zone load balancing for lb"
  default     = false
}

// -------------General(optional)---------------
variable "prefix" {
  type        = string
  description = "project prefix added to all resources created"
  default     = "EFA"
}

variable "policy_arn_attachments" {
  type        = list(string)
  description = "list of  policies that needs to be attached"
  default     = []
}

// app variables
variable "app_image" {
  type        = string
  description = "docker image or by default creates ECS repo"
  default     = "none"
}

variable "min_task_count" {
  type        = number
  description = "minimum number of app containers running"
  default     = 1
}

variable "max_task_count" {
  type        = number
  description = "minimum number of app containers running"
  default     = 10
}

variable "extra_ports" {
  type        = list(string)
  description = "additional ports to expose. useful case: rabbitmq"
  default     = []
}

variable "secrets" {
  description = "allow fargate task access to secret manager secrets."
  default     = []
}

variable "parameters" {
  description = "allow farget task to access parameter store"
  default     = []
}

// load balancer variables
variable "certificate" {
  type        = bool
  description = "create ceritificate resurces if value true"
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "set to true to add ssl to alb"
  default     = "none"
}

variable "nlb_stickiness" {
  type        = bool
  description = "enable stickiness for network load balancer"
  default     = false
}

// Health check variables
variable "health_check" {
  type        = bool
  description = "enable healthcheck for taget group"
  default     = true
}

variable "health_check_timeout" {
  type        = number
  description = "set timeout for healthcheck in seconds"
  default     = 10
}

variable "health_check_path" {
  type        = string
  description = "set healthcheck path for instance"
  default     = "/"
}

// add xray to task definition
variable "xray" {
  type        = bool
  description = "add xray daemon as sidecar"
  default     = false
}

// tags
variable "tags" {
  type        = map(string)
  description = "tags to add to all resources created with this module"
  default = {
    Terraform = "true"
    Module    = "ecs-fargate"
  }
}

// -------------Fargate variables(optional)------------------

// fargate cluster Variables
variable "fargate_cpu" {
  type        = string
  description = "fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  type        = string
  description = "fargate instance memory to provision (in MiB)"
  default     = "2048"
}

// ------- service connect configuration -------

variable "service_connect_enabled" {
  type = bool
  description = "to enable service connect"
  default = false
}

variable "cloudmap_namespace_arn" {
  type = string
  description = "Arn of registered cloudmap namespace"
}

variable "sc_ingress_port_override" {
  type = string
  description = "port number for proxy to listen on if not default, which is container port in case of ecs fargate"
  default = null
}

variable "target_group_arn" {
  type = string
  description = "load balancer target group arn"
}

variable "lb_listener_rule" {
  description = "load balancer listener"
}
