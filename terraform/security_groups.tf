# ========================================
# Lambda Security Group
# ========================================

resource "aws_security_group" "lambda" {
  name_prefix = "${var.project_name}-${var.environment}-lambda-"
  description = "Security group for Lambda function"
  vpc_id      = module.vpc.vpc_id

  # Egress rules for VPC Endpoints
  egress {
    description = "Allow HTTPS to VPC Endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all outbound (needed for VPC endpoints)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-lambda-sg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# VPC Endpoint Security Group
# ========================================

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-${var.environment}-vpce-"
  description = "Security group for VPC Endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow HTTPS from Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-vpce-sg"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}
