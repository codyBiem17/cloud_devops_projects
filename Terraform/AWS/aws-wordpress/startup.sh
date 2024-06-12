#!/bin/sh

# Update the package manager
sudo yum update -y

# Install Apache
sudo yum install httpd -y

# Start the Apache service
sudo systemctl start httpd

# Ensure Apache starts on every boot
sudo systemctl enable httpd

# Install PHP and necessary modules
#sudo yum install -y php php-dom php-gd php-mysql
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable php8.2
sudo yum clean metadata
sudo yum install -y php-cli php-pdo php-fpm php-json php-mysqlnd

# Install MySql client to interact with RDS
sudo yum install -y mysql

# Install wget package
sudo yum install -y wget

# Enter the web server's directory
cd /var/www/html

# Fetch the latest WordPress package
sudo wget https://wordpress.org/latest.tar.gz

# Unpack the magic
sudo tar -xzvf latest.tar.gz

# Move wordpress files to documentroot directory
sudo cp -r wordpress/* .

# Adjust permissions and ownership
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/html

# Create copy of default config file
cp wp-config-sample.php wp-config.php

# Adjust database connection strings
sudo sed -i "s/database_name_here/rds_wordpress_db/" wp-config.php
sudo sed -i "s/username_here/biem/" wp-config.php
sudo sed -i "s/password_here/*Maryambello09*/" wp-config.php
sudo sed -i "s/localhost/terraform-20240530083707523500000003.c1osak4aqixk.us-west-2.rds.amazonaws.com/" wp-config.php

#  define('DB_NAME', 'rds_wordpress_db');
#  define('DB_USER', 'biem');
#  define('DB_PASSWORD', '*Maryambello09*');
#  define('DB_HOST', 'terraform-20240529111554714400000001.c1osak4aqixk.us-west-2.rds.amazonaws.com');
#

# Restart apache server
sudo systemctl restart httpd


