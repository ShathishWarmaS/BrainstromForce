# BrainstromForce
Assignment 

This project automates the deployment of a WordPress website using the LEMP stack (Linux, Nginx, MySQL, PHP) with GitHub Actions for CI/CD. It follows best practices for security and performance.

## Project Setup

- **Web Server**: Nginx
- **Database**: MySQL/MariaDB
- **Scripting Language**: PHP
- **Automation**: GitHub Actions

### Goals

- Secure, optimized deployment of WordPress on a VPS
- Automated CI/CD with GitHub Actions
- SSL/TLS configuration using Let's Encrypt
- Optimized Nginx for caching and performance

## WordPress Deployment with Terraform and GitHub Actions

This project automates the deployment of a WordPress website on an AWS EC2 instance using Terraform and GitHub Actions for CI/CD. The setup includes an Nginx web server, MySQL database, PHP configuration, and SSL via Let’s Encrypt.

# Table of Contents

	•	Prerequisites
	•	Project Setup
	•	Terraform Configuration
	•	GitHub Actions Setup
	•	Security and Best Practices
	•	Notes

# Prerequisites

	1.	AWS Account: Ensure you have an AWS account and IAM user credentials with permissions to manage EC2, Route 53, and security groups.
	2.	Terraform: Install Terraform on your local machine. Installation Guide.
	3.	GitHub Repository: Create a GitHub repository for the project, with Secrets configured for secure deployment.

# Project Setup

	1.	Clone the Repository:
    '''
    git clone https://github.com/your-username/your-repo-name.git
    cd your-repo-name
    '''