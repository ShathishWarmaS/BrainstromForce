variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "SSH key pair name for access to the instance"
  type        = string
}

variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
}

variable "php_version" {
  description = "PHP version to install"
  type        = string
  default     = "7.4"
}

variable "wordpress_db_name" {
  description = "Database name for WordPress"
  type        = string
}

variable "wordpress_db_user" {
  description = "Database user for WordPress"
  type        = string
}

variable "wordpress_db_password" {
  description = "Database password for WordPress user"
  type        = string
}

variable "wordpress_site_title" {
  description = "Title of the WordPress site"
  type        = string
}

variable "wordpress_admin_user" {
  description = "Admin username for WordPress"
  type        = string
}

variable "wordpress_admin_password" {
  description = "Admin password for WordPress"
  type        = string
}

variable "wordpress_admin_email" {
  description = "Admin email for WordPress"
  type        = string
}

variable "ssh_cidr_block" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0" # Change this to restrict SSH access as needed
}

variable "wordpress_url" {
  description = "URL for the WordPress site (IP or domain)"
  type        = string
}


variable "backup_dir" {
    description = "Directory for MySQL backups"
    type        = string
    default     = "/var/backups/mysql"  # Or any preferred default
}

# Route 53 Hosted Zone ID
variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID for the domain"
  type        = string
}