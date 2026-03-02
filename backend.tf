terraform {
  backend "s3" {
    bucket         = "terraform-state-da281549-5c33-41b0-9677-4d5ebe2b2e95"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    use_lockfile   = true
    encrypt        = true
  }
}
