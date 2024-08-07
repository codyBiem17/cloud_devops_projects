resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.resource_group_name
}

# Create virtual network
resource "azurerm_virtual_network" "terraform_vnet" {
  name                = "tfVnet"
  address_space       = var.vnet
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create public subnet
resource "azurerm_subnet" "terraform_public_subnet" {
  name                 = "tfSubnetPublic"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = [var.subnets[0]]
}

# Create private subnet for DB
resource "azurerm_subnet" "terraform_private_subnet" {
  name                 = "tfSubnetPrivate"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.terraform_vnet.name
  address_prefixes     = [var.subnets[1]]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


# Create public IPs
resource "azurerm_public_ip" "terraform_public_ip" {
  name                = "tfPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  domain_name_label = var.vm_name
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraform_nsg" {
  name                = "tfNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternetTraffic"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*" # "10.0.3.0/24"
  }

  security_rule {
    name                       = "AllowMySQLAccess"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*" # "10.0.3.0/24"
    destination_address_prefix = "*" # "10.0.5.0/24"
  }


}

# Create network interface
resource "azurerm_network_interface" "terraform_nic" {
  name                = "tfNIC"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "tf_nic_configuration"
    subnet_id                     = azurerm_subnet.terraform_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "vm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.terraform_nic.id
  network_security_group_id = azurerm_network_security_group.terraform_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "terraform_vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.terraform_nic.id]
  size                  = var.vm_size
  custom_data = filebase64("startup.sh")
  os_disk {
    name                 = "tfOsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username = var.vm_admin_username

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

}


# Create Azure Database - MySQL flexible servers
resource "azurerm_private_dns_zone" "tf_dns_zone" {
  name                = "private.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "tf-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.tf_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.terraform_vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

resource "azurerm_mysql_flexible_server" "tf_flexible_server" {
  name                   = "tf-mysql-flexible-server"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.location
  administrator_login    = var.db_server_username
  administrator_password = var.db_server_password
  delegated_subnet_id    = azurerm_subnet.terraform_private_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.tf_dns_zone.id
  sku_name               = var.server_sku

  depends_on = [azurerm_private_dns_zone.tf_dns_zone, azurerm_subnet.terraform_private_subnet, azurerm_private_dns_zone_virtual_network_link.vnet_link]
}

resource "azurerm_mysql_flexible_database" "tf_flexible_database" {
  name                = "tf-mysql-flexible-db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_flexible_server.tf_flexible_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# configure wp-config.php to dynamically use the terraform state
locals {
  wp_config = templatefile("${path.module}/wp-config.php.tpl", {
    db_name     = azurerm_mysql_flexible_database.tf_flexible_database.name
    db_user     = azurerm_mysql_flexible_server.tf_flexible_server.administrator_login
    db_password = azurerm_mysql_flexible_server.tf_flexible_server.administrator_password
    db_host     = azurerm_mysql_flexible_server.tf_flexible_server.fqdn
  })
}
