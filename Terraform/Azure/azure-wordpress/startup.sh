#!/bin/sh

# Update the package manager
sudo apt update -y

# Install Nginx
sudo apt install nginx -y

# Install PHP and necessary eextensions
sudo apt install php8.1-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php- xmlrpc php-zip

# Install MySql client to interact with Azure DB
sudo apt install -y mysql

# Enter the website's directory
cd /var/www/html

# Install wget package
#sudo yum install -y wget
# Fetch the latest WordPress package
sudo wget https://wordpress.org/latest.tar.gz

# Unpack the magic
sudo tar -xzvf latest.tar.gz

# Rename the WordPress directory for simplicity
sudo mv wordpress wordpress-tf.com

# Adjust permissions and ownership
sudo chown -R www-data:www-data wordpress-tf.com

# Change directory to renamed wp direcatory and create copy of default config file
cd wordpress-tf.com
cp wp-config-sample.php wp-config.php

# Adjust database connection strings
sudo sed -i "s/database_name_here/tf-mysql-flexible-db/" wp-config.php
sudo sed -i "s/username_here/server_admin/" wp-config.php
sudo sed -i "s/password_here/*Maryambello09*/" wp-config.php
sudo sed -i "s/localhost/tf-mysql-flexible-db.private.mysql.database.azure.com/" wp-config.php

# Set up Nginx server block for WordPress
cat > /etc/nginx/sites-available/wordpress-tf << 'EOF'
server {
       listen 80;
       listen [::]:80;

       server_name teraform-wordpress.com www.teraform-wordpress.com;

       root /var/www/html/wordpress-tf.com;
       index index.php index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}
EOF

ln -s /etc/nginx/sites-available/wordpress-tf /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Restart apache server
sudo systemctl restart nginx

