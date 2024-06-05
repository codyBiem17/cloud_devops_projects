variable "instance_type" {
  description = "instance type for the ec2 instance"
}

variable "vpc_cidr" {
  description = "cidr range for vpc"
}

variable "pub_subnet_cidr" {
  description = "public subnet for EC2 instance"
}

variable "priv_subnet_cidr" {
  description = "private subnet for RDS"
  type = list(string)
}

variable "db_storage" {}
variable "db_name" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_master_username" {}
variable "db_user_password" {}
variable "db_param_group_name" {}



#variable "public_key" {
 # description = "public key file path for ec2"
#}

