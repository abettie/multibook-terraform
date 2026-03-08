output "hosted_zone_name_servers" {
  description = "Name servers for the Route53 hosted zone (set these in your domain registrar)"
  value       = module.hosted_zone.name_servers
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "web_cloudfront_distribution_id" {
  description = "The ID of the web CloudFront distribution"
  value       = module.web_cloudfront.distribution_id
}

output "image_cloudfront_distribution_id" {
  description = "The ID of the image CloudFront distribution"
  value       = module.image_cloudfront.distribution_id
}
