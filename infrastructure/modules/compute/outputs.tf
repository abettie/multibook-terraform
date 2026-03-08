output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "key_name" {
  description = "The name of the key pair"
  value       = aws_key_pair.main.key_name
}
