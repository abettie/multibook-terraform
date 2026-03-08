variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "zone_domain" {
  description = "Root domain name for the Route53 hosted zone"
  type        = string
}

variable "app_domain" {
  description = "Domain name for the web application"
  type        = string
}

variable "image_domain" {
  description = "Domain name for the image CDN"
  type        = string
}

variable "image_s3_bucket" {
  description = "S3 bucket name for images"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
}

variable "image_cache_ttl" {
  description = "Cache TTL in seconds for the image CloudFront distribution"
  type        = number
  default     = 1
}
