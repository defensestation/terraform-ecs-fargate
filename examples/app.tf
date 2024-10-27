provider "aws" {
  region  = "us-east-1"
}

# creating VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0" 

  name = "test_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a","us-east-1b"]

  private_subnets = ["10.0.51.0/24","10.0.52.0/24"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "test.local"
  description = "all services will be registered under this common namespace"
  vpc         = module.vpc.vpc_id
}


resource "aws_service_discovery_service" "app" {
  name = "app.test.local"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

module "test" {
  source            = "./../"
  region            = "us-east-1"
  app_name          = "app"
  app_port          = "80"
  env               = "dev"
  vpc               = module.vpc
  app_image         = "nginx:1.13.9-alpine"
  service_connect_enabled = true
  cloudmap_namespace_arn = aws_service_discovery_service.app.arn
}