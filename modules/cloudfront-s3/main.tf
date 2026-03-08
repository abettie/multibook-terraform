# CloudFront OAC(画像用S3バケット)
resource "aws_cloudfront_origin_access_control" "image" {
  name                              = "terra-image-oac"
  description                       = "OAC for terra-image S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFrontキャッシュポリシー
resource "aws_cloudfront_cache_policy" "image" {
  name        = "terra-image-cache-policy"
  default_ttl = var.cache_ttl
  min_ttl     = var.cache_ttl
  max_ttl     = var.cache_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

# 403用レスポンスヘッダポリシー(空ページ返却用)
resource "aws_cloudfront_response_headers_policy" "image_403" {
  name = "terra-image-403-policy"
  custom_headers_config {
    items {
      header   = "Cache-Control"
      value    = "no-store"
      override = true
    }
  }
}

# CloudFrontディストリビューション(画像用)
resource "aws_cloudfront_distribution" "image" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "terra-image-cloudfront"
  aliases             = [var.domain_name]
  default_root_object = ""

  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = "terra-image-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.image.id
  }

  default_cache_behavior {
    target_origin_id           = "terra-image-s3"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = aws_cloudfront_cache_policy.image.id
    compress                   = true
    response_headers_policy_id = aws_cloudfront_response_headers_policy.image_403.id
  }

  ordered_cache_behavior {
    path_pattern           = "/thumbnails/*"
    target_origin_id       = "terra-image-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.image.id
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern           = "/images/*"
    target_origin_id       = "terra-image-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.image.id
    compress               = true
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
}

# S3バケットポリシー(CloudFront OACからのアクセスのみ許可)
resource "aws_s3_bucket_policy" "image" {
  bucket = var.s3_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = ["s3:GetObject"]
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.image.arn
          }
        }
      }
    ]
  })
}
