# ========================================
# VPC Module
# Using official AWS VPC Terraform module
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/6.5.1
# ========================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Internet Gateway for public subnets
  create_igw = true

  # NAT Gateway configuration (disabled for cost optimization)
  # Using VPC Endpoints for ECR access instead
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # DNS settings
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags
  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-vpc"
      Environment = var.environment
      Project     = var.project_name
    },
    var.additional_tags
  )

  public_subnet_tags = {
    Type = "Public"
  }

  private_subnet_tags = {
    Type = "Private"
  }

  vpc_tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}
