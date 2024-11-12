# Output the EC2 instance ID
output "instance_id" {
  description = "The ID of the WordPress EC2 instance"
  value       = aws_instance.wordpress.id
  # Provides the unique identifier (ID) for the WordPress EC2 instance.
  # Useful for referencing this specific instance in other resources or modules.
}

# Output the Amazon Resource Name (ARN) of the EC2 instance
output "instance_arn" {
  description = "The ARN of the WordPress EC2 instance"
  value       = aws_instance.wordpress.arn
  # Provides the ARN (Amazon Resource Name) for the WordPress EC2 instance.
  # ARNs are globally unique and used to identify AWS resources across accounts and services.
}

# Output the private IP address of the EC2 instance
output "instance_private_ip" {
  description = "The private IP address of the WordPress EC2 instance"
  value       = aws_instance.wordpress.private_ip
  # Provides the private IP address assigned to the WordPress EC2 instance within the VPC.
  # This is useful for internal communications within the VPC and for security-sensitive applications.
}

# Output the public IP address of the instance
output "public_ip" {
  description = "The public IP address of the WordPress EC2 instance"
  value       = aws_eip.wordpress_eip.public_ip
  # Provides the Elastic IP (public IP) assigned to the WordPress EC2 instance.
  # This is useful for accessing the WordPress site from the internet or external networks.
}