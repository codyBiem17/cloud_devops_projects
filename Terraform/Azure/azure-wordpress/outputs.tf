output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_public_ip_address" {
  value = azurerm_linux_virtual_machine.terraform_vm.public_ip_address
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "dns_name" {
  value = azurerm_public_ip.public_ip.fqdn
}
