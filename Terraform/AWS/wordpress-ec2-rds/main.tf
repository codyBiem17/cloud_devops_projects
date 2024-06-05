terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16" #provider version
    }
  }

  required_version = ">= 1.7.5" #terraform version

  backend "s3" {
    bucket = "tf-s3-backend-store"
    key    = "s3-backend"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["851725202131"]
    }
    actions = [ "s3:ListBucket", "s3:GetObject", "s3:PutObject" ]
    resources =  [ aws_s3_bucket.backend_store.arn, "${aws_s3_bucket.backend_store.arn}/*" ]
  }

}

resource "aws_s3_bucket" "backend_store" {
  bucket = "tf-s3-backend-store"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

}

resource "aws_s3_bucket_policy" "attach_bucket_policy" {
  bucket = aws_s3_bucket.backend_store.id
  policy = data.aws_iam_policy_document.bucket_policy.json
 }

data "aws_ami" "amazon" {
  #most_recent = true

  owners = ["137112412989"] #Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240521.0-x86_64-gp2"]
  }

  #filter {
   # name = "virtualization-type"
    #values = ["hvm"]
 # }
}

#resource "aws_key_pair" "deployer-key" {
#  key_name   = "wordpress_keypair"
#  public_key = file("wordpress_key.pub")
#}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.amazon.id
  instance_type = var.instance_type
#  key_name = aws_key_pair.deployer-key.key_name
  subnet_id = aws_subnet.public_subnet.id
  user_data = <<-EOF
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

  # Install MySql
  sudo yum install -y mysql

  # Start the MySql service
  sudo systemctl start mysqld

  # Ensure MySql starts on every boot
  sudo systemctl enable mysqld

  
  # Install wget package
  sudo yum install -y wget
  
  # Enter the web server's directory
  cd /var/www/html

  # Install wget package
  #sudo yum install -y wget

  # Fetch the latest WordPress package
  sudo wget https://wordpress.org/latest.tar.gz

  # Unpack the magic
  sudo tar -xzvf latest.tar.gz

  # Rename the WordPress directory for simplicity
  sudo mv wordpress wordpress-tf

  sudo usermod -a -G apache ec2-user

  # Adjust permissions and ownership
  sudo chown -R ec2-user:apache wordpress-tf

  # Change directory to renamed wp direcatory and create copy of default config file
  cd wordpress-tf
  cp wp-config-sample.php wp-config.php

  # Open and modify settings in config.php
  # sudo nano wp-config.php

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
  sudo systemctl httpd restart
  
  EOF

  vpc_security_group_ids = [ aws_security_group.tf_ec2_security_group.id ]

  associate_public_ip_address = true
 
  tags = {
    Name = "tf_wordpress_server"
  }
}

resource "aws_vpc" "wp_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = "true"

  tags = {
    Name = "tf-vpc"
  }
}

output "ec2_ip" {
  value = aws_instance.app_server.public_ip
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.wp_vpc.id
  cidr_block = var.pub_subnet_cidr
  availability_zone = "us-west-2a"

  depends_on = [
    aws_vpc.wp_vpc
  ]

  tags = {
    Name = "tf_pub_subnet"
  }

}

resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.wp_vpc.id
  cidr_block = var.priv_subnet_cidr[0]
  availability_zone = "us-west-2b"

  depends_on = [
    aws_vpc.wp_vpc
 ]

  tags = {
    Name = "tf_priv_subnet1"
  }


}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.wp_vpc.id
  cidr_block = var.priv_subnet_cidr[1]
  availability_zone = "us-west-2c"

  depends_on = [
    aws_vpc.wp_vpc
 ]

  tags = {
    Name = "tf_priv_subnet2"
  }


}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.wp_vpc.id

  depends_on = [
    aws_vpc.wp_vpc
  ]
  
  tags = {
    Name = "tf_igw"
  }

}

resource "aws_route_table" "tf_public_route_table" {
  vpc_id = aws_vpc.wp_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  depends_on = [
    aws_vpc.wp_vpc
 ]

  tags = {
    Name = "tf_pub_rt"
  }

}

resource "aws_route_table_association" "rt_public_sub_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.tf_public_route_table.id

  depends_on = [
    aws_subnet.public_subnet
  ]
}

#route table and association for private subnet AZ1

resource "aws_route_table" "tf_priv_subnet1_rt" {
  vpc_id = aws_vpc.wp_vpc.id

  depends_on = [
    aws_vpc.wp_vpc
 ]

  tags = {
    Name = "tf_priv_rt1"
  }

}

resource "aws_route_table_association" "rt_priv_subnet1_assoc" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.tf_priv_subnet1_rt.id

  depends_on = [
    aws_subnet.private_subnet1
  ]
}

#route table and association for private subnet AZ2

resource "aws_route_table" "tf_priv_subnet2_rt" {
  vpc_id = aws_vpc.wp_vpc.id

  depends_on = [
    aws_vpc.wp_vpc
 ]

  tags = {
    Name = "tf_priv_rt2"
  }

}

resource "aws_route_table_association" "rt_priv_subnet2_assoc" {
  subnet_id = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.tf_priv_subnet2_rt.id

  depends_on = [
    aws_subnet.private_subnet2
  ]
}


resource "aws_security_group" "tf_ec2_security_group" {
  vpc_id = aws_vpc.wp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "tf_sg"
  }

}


resource "aws_security_group" "tf_rds_security_group" {
  vpc_id = aws_vpc.wp_vpc.id

# NSG rule for allow inbound RDS connection
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
    Name = "tf_rds_sg"
  }

}

#the subnet-group resource designates a collection of subnets that your RDS instance can be provisioned in. This subnet group uses the subnets created by the VPC module.

resource "aws_db_subnet_group" "rds_subnet_group" {
  name= "rds-db-subnet"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_instance" "rds_instance" {
  allocated_storage    = var.db_storage
  db_name              = var.db_name
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  username             = var.db_master_username
  password             = var.db_user_password
  parameter_group_name = var.db_param_group_name
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [ aws_security_group.tf_rds_security_group.id ]
}



