/* 
Module: ECS-Fargate-ServiceConnect
Version: 1.0.0

This file will create following:
  - elastic container registry to store app docker image
*/

// create ecr registry
resource "aws_ecr_repository" "ecr_repo" {
  // run only if app image is not provided and don't if virtual gateway is provided
  count = (var.app_image != "none") ? 0 : 1
  // name can be in lower case only
  name                 = lower("${var.prefix}-${var.env}-${var.app_name}")
  image_tag_mutability = "IMMUTABLE"

  // scan image configuration
  image_scanning_configuration {
    scan_on_push = true
  }

  dynamic "encryption_configuration" {
    for_each = [var.ecr_kms_key_arn]
    content {
      encryption_type = "KMS"
      // it is upto user to provide the kms keys
      kms_key         = encryption_configuration.value #tfsec:ignore:aws-ecr-repository-customer-key
    } 
  }

  // add tags
  tags = var.tags
}