terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-stg-20c4f2da-888b-fb2b-9b8f-bac50c649cb7"
    key          = "terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "staging"
      ManagedBy   = "Terraform"
      Project     = "multibook"
    }
  }
}

# CloudFront用ACM証明書はus-east-1が必須
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "staging"
      ManagedBy   = "Terraform"
      Project     = "multibook"
    }
  }
}

module "hosted_zone" {
  source = "../modules/route53-hosted-zone"

  domain_name = var.zone_domain
  environment = "staging"
}

module "network" {
  source = "../modules/network"

  aws_region = var.aws_region
}

module "security" {
  source = "../modules/security"

  vpc_id = module.network.vpc_id
}

# 東京リージョン用ACM証明書(ALB用)
module "acm_tokyo" {
  source = "../modules/acm-certificate"

  domain_name     = var.app_domain
  route53_zone_id = module.hosted_zone.zone_id
  environment     = "staging"
}

# バージニアリージョン用ACM証明書(Webアプリ CloudFront用)
module "acm_app_virginia" {
  source = "../modules/acm-certificate"

  providers = {
    aws = aws.us_east_1
  }

  domain_name     = var.app_domain
  route53_zone_id = module.hosted_zone.zone_id
  environment     = "staging"
}

# バージニアリージョン用ACM証明書(画像 CloudFront用)
module "acm_image_virginia" {
  source = "../modules/acm-certificate"

  providers = {
    aws = aws.us_east_1
  }

  domain_name     = var.image_domain
  route53_zone_id = module.hosted_zone.zone_id
  environment     = "staging"
}

module "compute" {
  source = "../modules/compute"

  subnet_id     = module.network.subnet_public_a_id
  default_sg_id = module.security.default_sg_id
  ec2_sg_id     = module.security.ec2_sg_id
  public_key    = var.public_key
  instance_type = var.instance_type
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  subnet_ids      = [module.network.subnet_public_a_id, module.network.subnet_public_c_id]
  default_sg_id   = module.security.default_sg_id
  elb_sg_id       = module.security.elb_sg_id
  vpc_id          = module.network.vpc_id
  certificate_arn = module.acm_tokyo.certificate_arn
  instance_id     = module.compute.instance_id
}

module "image_s3" {
  source = "../modules/s3-image"

  bucket_name = var.image_s3_bucket
  environment = "staging"
}

module "web_cloudfront" {
  source = "../modules/cloudfront-alb"

  domain_name     = var.app_domain
  alb_dns_name    = module.loadbalancer.alb_dns_name
  certificate_arn = module.acm_app_virginia.certificate_arn
  environment     = "staging"
}

module "image_cloudfront" {
  source = "../modules/cloudfront-s3"

  domain_name                    = var.image_domain
  s3_bucket_id                   = module.image_s3.bucket_id
  s3_bucket_arn                  = module.image_s3.bucket_arn
  s3_bucket_regional_domain_name = module.image_s3.bucket_regional_domain_name
  certificate_arn                = module.acm_image_virginia.certificate_arn
  environment                    = "staging"
  cache_ttl                      = var.image_cache_ttl
}

module "route53_records" {
  source = "../modules/route53-records"

  zone_id                         = module.hosted_zone.zone_id
  app_domain                      = var.app_domain
  app_cloudfront_domain_name      = module.web_cloudfront.distribution_domain_name
  app_cloudfront_hosted_zone_id   = module.web_cloudfront.distribution_hosted_zone_id
  image_domain                    = var.image_domain
  image_cloudfront_domain_name    = module.image_cloudfront.distribution_domain_name
  image_cloudfront_hosted_zone_id = module.image_cloudfront.distribution_hosted_zone_id
}
