output "msif_vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "msif_private_subnets_ids" {
  description = "Private subnets IDs"
  value       = module.vpc.private_subnets
}

output "msif_public_subnets_ids" {
  description = "Public subnets IDs"
  value       = module.vpc.public_subnets
}