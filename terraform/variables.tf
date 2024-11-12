# AWS region where resources will be deployed
variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "us-east-1"  # Default is "us-east-1"; adjust as needed
}

# Amazon Machine Image (AMI) ID for the EC2 instance
# This specifies the base OS image for the instance. Ensure it's compatible with your requirements.
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

# Instance type for the EC2 instance
# "t2.micro" is suitable for testing or low-traffic sites. For production, consider a larger instance type.
variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# Name of the SSH key pair for accessing the EC2 instance
# This key pair should already exist in AWS and be accessible in the specified region.
variable "ssh_key_name" {
  description = "SSH key pair name for access to the instance"
  type        = string
}

# Root password for MySQL
# Used during the MySQL setup to secure the database server. Consider using a secure and unique password.
variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
}

# PHP version to install on the EC2 instance
# Specify the PHP version compatible with your WordPress setup. Ensure it's available in the selected AMI.
variable "php_version" {
  description = "PHP version to install"
  type        = string
  default     = "7.4"  # Default PHP version, adjust as needed
}

# Database name for WordPress
# The name of the MySQL database that WordPress will use.
variable "wordpress_db_name" {
  description = "Database name for WordPress"
  type        = string
}

# MySQL user for the WordPress database
# This user will have privileges on the WordPress database to perform necessary operations.
variable "wordpress_db_user" {
  description = "Database user for WordPress"
  type        = string
}

# Password for the WordPress database user
# This password will be used by WordPress to connect to the database. Use a secure password.
variable "wordpress_db_password" {
  description = "Database password for WordPress user"
  type        = string
}

# Title for the WordPress site
# This is the main title that will be displayed on the site and in the admin dashboard.
variable "wordpress_site_title" {
  description = "Title of the WordPress site"
  type        = string
}

# WordPress admin username
# Used to log into the WordPress admin dashboard with full access.
variable "wordpress_admin_user" {
  description = "Admin username for WordPress"
  type        = string
}

# WordPress admin password
# Password for the admin user. Use a secure and unique password to protect access.
variable "wordpress_admin_password" {
  description = "Admin password for WordPress"
  type        = string
}

# Email address for the WordPress admin user
# Used for account recovery, notifications, and administrative emails.
variable "wordpress_admin_email" {
  description = "Admin email for WordPress"
  type        = string
}

# CIDR block for SSH access
# Use a specific IP or range (e.g., "192.168.1.0/24") to restrict SSH access. "0.0.0.0/0" allows access from any IP.
variable "ssh_cidr_block" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # Adjust for enhanced security
}

# Domain or IP address for the WordPress site
# Used to set up the WordPress site and configure Nginx and SSL settings.
variable "wordpress_url" {
  description = "URL for the WordPress site (IP or domain)"
  type        = string
}

# Directory for storing MySQL backups
# Default is "/var/backups/mysql"; adjust to store backups in a different location if needed.
variable "backup_dir" {
    description = "Directory for MySQL backups"
    type        = string
    default     = "/var/backups/mysql"
}

# Route 53 hosted zone ID
# Used to configure DNS settings for the domain in AWS Route 53.
variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID for the domain"
  type        = string
}