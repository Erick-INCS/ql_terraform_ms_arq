output "msif_dns_discovery_id" {
  description = "MS IF service discovery id"
  value       = aws_service_discovery_private_dns_namespace.msif_dns_discovery.id
}

output "msif_private_dns_namespace" {
  description = "Service discovery id"
  value       = aws_service_discovery_private_dns_namespace.msif_dns_discovery.name
}