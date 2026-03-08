# Terraform状態保存用S3バケット
resource "aws_s3_bucket" "terraform_state" {
  provider = aws.tokyo
  bucket   = "terraform-state"

  # 誤って削除されないように保護（本番環境では true を推奨）
  force_destroy = true

}

# バージョニング有効化（状態ファイルの履歴を保持）
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
