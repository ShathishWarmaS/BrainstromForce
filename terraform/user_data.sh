#!/bin/bash

# Enable logging for debugging by redirecting all output to a log file
exec > /var/log/user_data.log 2>&1

# Set environment variables for MySQL, PHP, and WordPress configurations
MYSQL_ROOT_PASSWORD="your_mysql_root_password"
PHP_VERSION="8.1"
WORDPRESS_DB_NAME="wordpress_db"
WORDPRESS_DB_USER="wp_user"
WORDPRESS_DB_PASSWORD="your_wp_password"
WORDPRESS_SITE_TITLE="My WordPress Site"
WORDPRESS_ADMIN_USER="admin"
WORDPRESS_ADMIN_PASSWORD="your_admin_password"
WORDPRESS_ADMIN_EMAIL="shathishwarma@gmail.com"
WORDPRESS_URL="brainstrom.shavini.xyz"
BACKUP_DIR="/var/backups/mysql"

# Log the set environment variables to verify they are correctly assigned
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
echo "PHP_VERSION: $PHP_VERSION"
echo "WORDPRESS_DB_NAME: $WORDPRESS_DB_NAME"
echo "WORDPRESS_DB_USER: $WORDPRESS_DB_USER"
echo "WORDPRESS_DB_PASSWORD: $WORDPRESS_DB_PASSWORD"
echo "WORDPRESS_SITE_TITLE: $WORDPRESS_SITE_TITLE"
echo "WORDPRESS_ADMIN_USER: $WORDPRESS_ADMIN_USER"
echo "WORDPRESS_ADMIN_PASSWORD: $WORDPRESS_ADMIN_PASSWORD"
echo "WORDPRESS_ADMIN_EMAIL: $WORDPRESS_ADMIN_EMAIL"
echo "WORDPRESS_URL: $WORDPRESS_URL"
echo "BACKUP_DIR: $BACKUP_DIR"

# Update system packages and install necessary software packages
sudo apt update && sudo apt upgrade -y
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"
sudo apt install -y mysql-server nginx php${PHP_VERSION}-cli php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql certbot python3-certbot-nginx

# Start MySQL service and allow time for initialization
sudo systemctl start mysql
sleep 10

# Configure MySQL: remove default users, create the WordPress database and user with permissions
sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DB_NAME};
CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'localhost' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Verify the MySQL database connection
if ! mysql -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "USE ${WORDPRESS_DB_NAME};" 2>/dev/null; then
    echo "Database connection failed for user ${WORDPRESS_DB_USER} on ${WORDPRESS_DB_NAME}" >&2
    exit 1
else
    echo "Database connection successful."
fi

# Set up the WordPress directory and adjust permissions
sudo mkdir -p /var/www/html/wordpress
sudo chown -R $USER:$USER /var/www/html/wordpress

# Download and extract the latest WordPress package
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mv wordpress/* /var/www/html/wordpress/

# Configure the wp-config.php file with database credentials
sudo cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wordpress/wp-config.php
sudo sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wordpress/wp-config.php

# Enhance security by disabling file edits from the WordPress admin panel
sudo tee -a /var/www/html/wordpress/wp-config.php > /dev/null <<EOF
define('DISALLOW_FILE_EDIT', true);
EOF

# Install wp-cli for additional WordPress management commands
if curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; then
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
else
    echo "wp-cli download failed. Exiting script."
    exit 1
fi

# Set appropriate permissions and ownership for WordPress files and directories
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo find /var/www/html/wordpress -type d -exec chmod 755 {} \;
sudo find /var/www/html/wordpress -type f -exec chmod 644 {} \;

# Configure Nginx with optimized settings for WordPress
sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default
sudo tee /etc/nginx/sites-available/wordpress <<EOF
server {
    listen 80;
    server_name ${WORDPRESS_URL};

    root /var/www/html/wordpress;
    index index.php index.html;

    # Enable Gzip Compression for performance
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied any;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml+rss text/javascript image/svg+xml;

    # Set caching headers for static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 365d;
        add_header Cache-Control "public, no-transform";
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable the new Nginx configuration and restart the service
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Obtain an SSL certificate with Certbot and configure Nginx for HTTPS
sudo certbot --nginx -d "$WORDPRESS_URL" --non-interactive --agree-tos --email "$WORDPRESS_ADMIN_EMAIL" --redirect
sudo systemctl restart nginx  # Restart Nginx with updated SSL configuration

# Use wp-cli to install WordPress with specified credentials
sudo -u www-data wp core install \
  --path=/var/www/html/wordpress \
  --url="https://${WORDPRESS_URL}" \
  --title="${WORDPRESS_SITE_TITLE}" \
  --admin_user="${WORDPRESS_ADMIN_USER}" \
  --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
  --admin_email="${WORDPRESS_ADMIN_EMAIL}"

# Set up MySQL backup directory and schedule a cron job for daily backups
sudo mkdir -p ${BACKUP_DIR}
sudo chown -R ubuntu:ubuntu ${BACKUP_DIR}
echo "0 2 * * * /usr/bin/mysqldump ${WORDPRESS_DB_NAME} > ${BACKUP_DIR}/${WORDPRESS_DB_NAME}-\$(date +\%F).sql" | sudo tee /etc/cron.d/mysql_backup

# Test automatic SSL certificate renewal with Certbot
sudo certbot renew --dry-run