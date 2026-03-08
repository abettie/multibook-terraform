# 画像用S3バケット
resource "aws_s3_bucket" "image" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "image" {
  bucket = aws_s3_bucket.image.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "image" {
  depends_on = [aws_s3_bucket_ownership_controls.image]
  bucket     = aws_s3_bucket.image.id
  acl        = "private"
}
