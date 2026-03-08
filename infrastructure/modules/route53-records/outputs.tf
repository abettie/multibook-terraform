output "app_record_fqdn" {
  description = "The FQDN of the app Route53 record"
  value       = aws_route53_record.app_cloudfront.fqdn
}

output "image_record_fqdn" {
  description = "The FQDN of the image Route53 record"
  value       = aws_route53_record.image_cloudfront.fqdn
}
