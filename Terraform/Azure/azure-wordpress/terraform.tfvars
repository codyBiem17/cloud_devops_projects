location = "northeurope"

resource_group_name = "TF-RG"

vnet = ["10.0.0.0/16"]

subnets = ["10.0.3.0/24", "10.0.5.0/24"]

vm_admin_username = "biem"

vm_size = "Standard_DS1_v2"

vm_name = "tfVM-wordpress"

storage_type = "Standard_LRS"

db_server_username = "server_admin"

server_sku = "B_Standard_B1s"
