output "default_sg_id" {
  description = "The ID of the default security group"
  value       = aws_security_group.default.id
}

output "ec2_sg_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "elb_sg_id" {
  description = "The ID of the ELB security group"
  value       = aws_security_group.elb.id
}
