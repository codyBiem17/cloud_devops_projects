# declare variables in root module

variable "statefile_bucket" {
  type = string
  description = "S3 bucket for terraform  remote statefiles"
}

variable "apache_bucket" {
  type = string
  description = "S3 bucket to store webserver config"
}


variable "dynamoDB_for_state_locking" {
  type = string
  description = "configure state locking on dynamoDb"
}


