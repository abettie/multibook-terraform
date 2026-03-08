terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "multibook"
    }
  }
}

# stg環境用 Terraform状態管理S3バケット
# ※このバケットは terraform init の前に apply する必要があります
resource "aws_s3_bucket" "terraform_state_stg" {
  bucket        = var.stg_state_bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "terraform_state_stg" {
  bucket = aws_s3_bucket.terraform_state_stg.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_stg" {
  bucket = aws_s3_bucket.terraform_state_stg.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# prod環境用 Terraform状態管理S3バケット
resource "aws_s3_bucket" "terraform_state_prod" {
  bucket        = var.prod_state_bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

variable "stg_state_bucket_name" {
  description = "S3 bucket name for stg Terraform state"
  type        = string
}

variable "prod_state_bucket_name" {
  description = "S3 bucket name for prod Terraform state"
  type        = string
}

output "stg_state_bucket_name" {
  value = aws_s3_bucket.terraform_state_stg.id
}

output "prod_state_bucket_name" {
  value = aws_s3_bucket.terraform_state_prod.id
}
