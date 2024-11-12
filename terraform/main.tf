# Configure the AWS provider
provider "aws" {
  region = var.aws_region  # Specify the AWS region, e.g., "us-east-1"
}

# Define security group for EC2 instance that will host the WordPress site
resource "aws_security_group" "wordpress_sg" {
  name = "wordpress-sg"  # Name of the security group

  # Inbound rule to allow SSH access from a specified IP range
  ingress {
    from_port   = 22              # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]  # Restrict SSH access to specific IPs for security
  }

  # Inbound rule to allow HTTP access on port 80 from a specified IP range
  ingress {
    from_port   = 80              # HTTP port
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]  # Set this to "0.0.0.0/0" to allow public HTTP access if needed
  }

  # Inbound rule to allow HTTPS access on port 443 from a specified IP range
  ingress {
    from_port   = 443             # HTTPS port
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr_block]  # Set this to "0.0.0.0/0" to allow public HTTPS access if needed
  }

  # Outbound rule to allow all traffic from the instance to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # -1 indicates all protocols
    cidr_blocks = [var.ssh_cidr_block]  # Allow all outbound traffic, e.g., for updates and API requests
  }
}

# Define the EC2 instance that will host the WordPress website
resource "aws_instance" "wordpress" {
  ami                    = var.ami_id                 # Amazon Machine Image ID for the desired OS
  instance_type          = var.instance_type          # EC2 instance type, e.g., "t2.micro"
  key_name               = var.ssh_key_name           # SSH key pair name for access to the instance
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]  # Attach the security group created above

  # Configure the root EBS volume for the instance
  root_block_device {
    volume_type = "gp3"          # Volume type (gp3 offers cost-effective general-purpose performance)
    volume_size = 30             # Size of the root volume in GB
  }

  # Pass necessary environment variables for WordPress setup using user data
  user_data = templatefile("user_data.sh", {        # user_data.sh contains the setup script for WordPress
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

  # Tags to help identify and manage the instance
  tags = {
    Name = "WordPress-Server"  # Tag to easily identify the instance in the AWS Console
  }
}

# Allocate an Elastic IP (EIP) and associate it with the EC2 instance
resource "aws_eip" "wordpress_eip" {
  instance = aws_instance.wordpress.id  # Associate the EIP with the WordPress EC2 instance
  vpc      = true                       # Ensures the EIP is allocated within the VPC
}

# Create a DNS A record in Route 53 to point to the Elastic IP of the WordPress instance
resource "aws_route53_record" "wordpress_dns" {
  zone_id = var.route53_zone_id         # Hosted zone ID in Route 53 for the domain
  name    = "brainstrom.shavini.xyz"    # Full domain name for the WordPress site (replace with your actual domain)
  type    = "A"                         # Record type 'A' for IP addresses
  ttl     = 300                         # Time-to-live for the DNS record, in seconds

  # Set the DNS record to point to the public IP of the Elastic IP
  records = [aws_eip.wordpress_eip.public_ip]
}