# EC2 Instance Connect Endpoint
resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = var.subnet_id
  security_group_ids = [var.default_sg_id]
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
  user_data                   = <<-EOF
    #!/bin/bash
    sudo dnf -y upgrade
    sudo dnf -y install nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF
}
