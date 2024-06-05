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
sudo yum install -y php php-dom php-gd php-mysql

# Install MariaDB
sudo yum install -y mariadb-server

# Start the MariaDB service
sudo systemctl start mariadb

# Ensure MariaDB starts on every boot
sudo systemctl enable mariadb



# Enter the web server's directory
#cd /var/www/html

# Fetch the latest WordPress package
#sudo wget https://wordpress.org/latest.tar.gz

# Unpack the magic
#sudo tar -xzvf latest.tar.gz

# Rename the WordPress directory for simplicity
#sudo mv wordpress wordpress-tf

# Adjust permissions and ownership
#sudo chown -R apache:apache wordpress-tf

