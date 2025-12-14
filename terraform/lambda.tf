# ========================================
# Lambda Function using Terraform Module
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/8.1.2
# ========================================
# 
# DEPLOYMENT:
# 1. ECR repository created
# 2. Docker image built and pushed (via null_resource)
# 3. Lambda function created with the image
# ========================================

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.1.2"

  function_name = "${var.project_name}-${var.environment}"
  description   = "Simple Time Service - Returns timestamp and IP address"

  # Container image configuration
  create_package = false
  package_type   = "Image"
  image_uri      = var.lambda_image_uri != "" ? var.lambda_image_uri : "${aws_ecr_repository.main.repository_url}:latest"
  architectures  = [var.lambda_architecture]

  # VPC Configuration
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.lambda.id]
  attach_network_policy  = true

  # Function configuration
  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  # Environment variables
  environment_variables = {
    ENVIRONMENT = var.environment
    LOG_LEVEL   = "INFO"
  }

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = var.lambda_log_retention_days

  # Tags
  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-lambda"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )

  # Depends on VPC endpoints being ready AND Docker image being pushed
  depends_on = [
    aws_vpc_endpoint.ecr_api,
    aws_vpc_endpoint.ecr_dkr,
    aws_vpc_endpoint.s3,
    aws_vpc_endpoint.logs,
    null_resource.docker_build_push
  ]
}
