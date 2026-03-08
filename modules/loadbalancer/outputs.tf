output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.web.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ALB"
  value       = aws_lb.web.zone_id
}
