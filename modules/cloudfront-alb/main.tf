# CloudFrontログ保存用S3バケット
resource "aws_s3_bucket" "log" {
  bucket        = "log-${var.domain_name}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log" {
  depends_on = [aws_s3_bucket_ownership_controls.log]
  bucket     = aws_s3_bucket.log.id
  acl        = "log-delivery-write"
}

# CloudFrontディストリビューション(Webアプリケーション用)
resource "aws_cloudfront_distribution" "web" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "terra-cloudfront"
  aliases             = [var.domain_name]
  default_root_object = ""

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "terra-elb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      ip_address_type        = "ipv6"
    }
  }

  logging_config {
    bucket          = aws_s3_bucket.log.bucket_regional_domain_name
    include_cookies = false
    prefix          = "cloudfront-${var.domain_name}/"
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "terra-elb"
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = "83da9c7e-98b4-4e11-a168-04f0df8e2c65" # UseOriginCacheControlHeaders
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_200"

  depends_on = [aws_s3_bucket_acl.log]
}
