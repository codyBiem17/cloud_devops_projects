# defining vaariable for apache webserver config bucket

variable "apache_webconfig_bucket" {}

# defining variables for object files content types

variable "content_type" {
  default = {
    html = "text/html"
    yml = "text/yml"
  }
}
