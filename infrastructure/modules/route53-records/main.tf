# アプリケーションドメイン用Route53レコード(CloudFront用)
resource "aws_route53_record" "app_cloudfront" {
  zone_id = var.zone_id
  name    = var.app_domain
  type    = "A"
  alias {
    name                   = var.app_cloudfront_domain_name
    zone_id                = var.app_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# 画像ドメイン用Route53レコード(CloudFront用)
resource "aws_route53_record" "image_cloudfront" {
  zone_id = var.zone_id
  name    = var.image_domain
  type    = "A"
  alias {
    name                   = var.image_cloudfront_domain_name
    zone_id                = var.image_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
