# ========================================
# VPC Endpoints for Private ECR Access
# ========================================

# ECR API Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecr-api-endpoint"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# ECR Docker Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ecr-dkr-endpoint"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# S3 Gateway Endpoint (for ECR image layers)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-s3-endpoint"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}

# CloudWatch Logs Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-logs-endpoint"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )
}
