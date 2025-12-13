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
