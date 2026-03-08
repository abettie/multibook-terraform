variable "zone_id" {
  description = "The Route53 hosted zone ID"
  type        = string
}

variable "app_domain" {
  description = "Domain name for the app CloudFront record"
  type        = string
}

variable "app_cloudfront_domain_name" {
  description = "Domain name of the app CloudFront distribution"
  type        = string
}

variable "app_cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the app CloudFront distribution"
  type        = string
}

variable "image_domain" {
  description = "Domain name for the image CloudFront record"
  type        = string
}

variable "image_cloudfront_domain_name" {
  description = "Domain name of the image CloudFront distribution"
  type        = string
}

variable "image_cloudfront_hosted_zone_id" {
  description = "Hosted zone ID of the image CloudFront distribution"
  type        = string
}
