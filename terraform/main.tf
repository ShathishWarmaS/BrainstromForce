provider "aws" {
  region = var.aws_region
}

# Define security group for EC2 instance
resource "aws_security_group" "wordpress_sg" {
  name = "wordpress-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ssh_cidr_block]
  }
}

# EC2 Instance for WordPress
resource "aws_instance" "wordpress" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  # Pass variables to user_data for WordPress installation
  user_data = templatefile("user_data.sh", {
    MYSQL_ROOT_PASSWORD       = var.mysql_root_password,
    PHP_VERSION               = var.php_version,
    WORDPRESS_DB_NAME         = var.wordpress_db_name,
    WORDPRESS_DB_USER         = var.wordpress_db_user,
    WORDPRESS_DB_PASSWORD     = var.wordpress_db_password,
    WORDPRESS_SITE_TITLE      = var.wordpress_site_title,
    WORDPRESS_ADMIN_USER      = var.wordpress_admin_user,
    WORDPRESS_ADMIN_PASSWORD  = var.wordpress_admin_password,
    WORDPRESS_ADMIN_EMAIL     = var.wordpress_admin_email,
    WORDPRESS_URL             = var.wordpress_url,
    BACKUP_DIR                = var.backup_dir
  })

  tags = {
    Name = "WordPress-Server"
  }
}

# Elastic IP Allocation
resource "aws_eip" "wordpress_eip" {
  instance = aws_instance.wordpress.id
  vpc      = true  # Specifies that the EIP is for use in a VPC
}

# Route 53 Record
resource "aws_route53_record" "wordpress_dns" {
  zone_id = var.route53_zone_id  # The Route 53 hosted zone ID
  name    = "brainstrom.shavini.xyz"  # Replace with your actual domain name
  type    = "A"
  ttl     = 300

  # Point the Route 53 record to the Elastic IP
  records = [aws_eip.wordpress_eip.public_ip]
}