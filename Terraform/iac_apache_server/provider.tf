provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region = var.aws_region
}

variable "aws_region" {
  default = "us-west-2"
}
