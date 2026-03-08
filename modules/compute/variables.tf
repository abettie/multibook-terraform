variable "subnet_id" {
  description = "The subnet ID for EC2 and Instance Connect Endpoint"
  type        = string
}

variable "default_sg_id" {
  description = "The ID of the default security group"
  type        = string
}

variable "ec2_sg_id" {
  description = "The ID of the EC2 security group"
  type        = string
}

variable "public_key" {
  description = "SSH public key for EC2 key pair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-027fff96cc515f7bc" # Amazon Linux 2023 (ap-northeast-1)
}
