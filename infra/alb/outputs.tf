output "msif_alb_sg_id" {
  description = "Private subnets ids"
  value       = aws_security_group.msif_alb_sg.id
}

output "msif_alb_id" {
  description = "Public alb"
  value       = aws_lb.msif_alb.id
}

output "msif_alb_dns_name" {
  description = "Public alb dns name"
  value       = aws_lb.msif_alb.dns_name
}

output "msif_alb_zone_id" {
  description = "Public alb zone id"
  value       = aws_lb.msif_alb.zone_id
}