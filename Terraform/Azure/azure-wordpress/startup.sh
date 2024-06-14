#!/bin/sh

# Update the package manager
sudo apt update -y

# Install Nginx
sudo apt install nginx -y

# Install PHP and necessary eextensions
sudo apt install php8.1-fpm php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php- xmlrpc php-zip

# Start and enable php-fpm service
sudo systemctl start php8.1-fpm
sudo systemctl enable php8.1-fpm

# Install MySql client to interact with Azure DB
sudo apt install mysql-client -y

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

# Dynamically adjust database connection strings
cat << 'EOF' > /var/www/html/wordpress-tf.com/wp-config.php
${local.wp_config}
EOF
#sudo sed -i "s/database_name_here/tf-mysql-flexible-db/" wp-config.php
#sudo sed -i "s/username_here/server_admin/" wp-config.php
#sudo sed -i "s/password_here/*Maryambello09*/" wp-config.php
#sudo sed -i "s/localhost/tf-mysql-flexible-server.private.mysql.database.azure.com/" wp-config.php

# Set up Nginx server block for WordPress
cat > /etc/nginx/sites-available/wordpress-tf << 'EOF'
server {
       listen 80;
       listen [::]:80;

       server_name tf-azure-vm.northeurope.cloudapp.azure.com;

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

