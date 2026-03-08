variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "default_sg_id" {
  description = "The ID of the default security group"
  type        = string
}

variable "elb_sg_id" {
  description = "The ID of the ELB security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener"
  type        = string
}

variable "instance_id" {
  description = "The ID of the EC2 instance to attach to the target group"
  type        = string
}
