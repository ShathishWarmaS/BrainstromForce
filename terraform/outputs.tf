output "instance_id" {
  description = "The ID of the WordPress EC2 instance"
  value       = aws_instance.wordpress.id
}



output "instance_arn" {
  description = "The ARN of the WordPress EC2 instance"
  value       = aws_instance.wordpress.arn
}

output "instance_private_ip" {
  description = "The private IP address of the WordPress EC2 instance"
  value       = aws_instance.wordpress.private_ip
}
# Output public IP of the instance
output "public_ip" {
  description = "The public IP address of the WordPress EC2 instance"
  value       = aws_eip.wordpress_eip.public_ip
}