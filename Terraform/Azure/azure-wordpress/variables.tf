variable "location" {
  type = string
  default = "westus"
}

variable "resource_group_name" {
  type = string
}

variable "vnet" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "vm_admin_username" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "vm_name" {
  type =  string
}

variable "storage_type" {
  type = string
}

variable "db_server_username" {
  type = string
}

variable "db_server_password" {
  type = string
}

variable "server_sku" {
  type = string
}
