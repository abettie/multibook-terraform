output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_public_a_id" {
  description = "The ID of the public subnet in AZ-a"
  value       = aws_subnet.public_a.id
}

output "subnet_public_c_id" {
  description = "The ID of the public subnet in AZ-c"
  value       = aws_subnet.public_c.id
}
