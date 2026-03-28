# EC2用IAMロール
resource "aws_iam_role" "ec2" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# 画像S3への読み書きポリシー
resource "aws_iam_role_policy" "s3_image" {
  name = "s3-image-policy"
  role = aws_iam_role.ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${var.image_s3_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = var.image_s3_bucket_arn
      }
    ]
  })
}

# EC2にロールをアタッチするInstance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2.name
}

# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = var.subnet_id
  security_group_ids = [var.default_sg_id]
  preserve_client_ip = false
}

# EC2用キーペア
resource "aws_key_pair" "main" {
  key_name   = "terra-key"
  public_key = var.public_key
}

# EC2インスタンス
resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.default_sg_id, var.ec2_sg_id]
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  user_data                   = <<-EOF
    #!/bin/bash
    sudo dnf -y upgrade
    sudo dnf -y install nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF
}
