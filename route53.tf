# Route53ホストゾーンを作成
resource "aws_route53_zone" "delegated" {
  name = var.zone_domain
}

# アプリケーションドメイン用Route53レコード(CloudFront用)
resource "aws_route53_record" "app_cloudfront" {
  zone_id = aws_route53_zone.delegated.zone_id
  name    = var.app_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53レコード(画像ドメイン用CloudFront・本番)
resource "aws_route53_record" "image_cloudfront" {
  zone_id = aws_route53_zone.delegated.zone_id
  name    = var.image_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.image.domain_name
    zone_id                = aws_cloudfront_distribution.image.hosted_zone_id
    evaluate_target_health = false
  }
}
