# ========================================
# VPC Outputs
# ========================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

# NAT Gateway outputs (disabled - using VPC Endpoints instead)
# output "nat_gateway_ips" {
#   description = "Elastic IPs of the NAT Gateways"
#   value       = module.vpc.nat_public_ips
# }

# ========================================
# ECR Outputs
# ========================================

output "ecr_repository_url" {
  description = "URL of the ECR repository (use this to push Docker images)"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.main.arn
}

# ========================================
# Lambda Outputs
# ========================================

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.lambda_function_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.lambda.lambda_role_arn
}

output "lambda_invoke_arn" {
  description = "ARN to invoke the Lambda function"
  value       = module.lambda.lambda_function_invoke_arn
}

# ========================================
# API Gateway Outputs
# ========================================

output "api_gateway_url" {
  description = "URL of the API Gateway endpoint (use this to test your application)"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.main.id
}

# ========================================
# Deployment Information
# ========================================

output "deployment_info" {
  description = "Quick reference for deployment information"
  value = {
    api_endpoint       = aws_apigatewayv2_stage.default.invoke_url
    lambda_function    = module.lambda.lambda_function_name
    ecr_repository_url = aws_ecr_repository.main.repository_url
    region             = var.aws_region
    environment        = var.environment
  }
}

# ========================================
# Deployment Message
# ========================================

output "deployment_message" {
  description = "Deployment completion message with API Gateway URL"
  value       = <<-EOT
  
  ========================================
  🚀 Deployment Complete!
  ========================================
  
  API Gateway URL: ${aws_apigatewayv2_stage.default.invoke_url}
  
  ⚠️  Please wait 15 seconds before testing.
  Cold start of Lambda is expected.
  
  ========================================
  
  Sincerely, Rohen
  
  EOT
}
