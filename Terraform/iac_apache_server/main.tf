module "s3" {
  source = "./modules/S3"
  bucket_name = var.statefile_bucket
}

module "apache_webconfig_s3" {
  source = "./modules/apache_webconfig_bucket"
  apache_webconfig_bucket = var.apache_bucket 
}

output "apache_user_arn" {
  value = "${module.s3.iam_user}"
}

module "dynamoDB" {
  source = "./modules/dynamoDB"
  dynamoDB_table = "dynamoDB_for_state_locking"
}

module "apache_vpc" {
 source = "./modules/vpc"
}

# create a backend S3 to store state files

terraform {
  backend "s3" {
    bucket = "terraform-s3-apache-bucket"
    key = "statefile/terraform.tfstate"
    dynamodb_table = "dynamoDB_for_state_locking"
    region = "us-west-2"
    encrypt = true
  }
}
