
output "vnet" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
  
}

output "subnet" {
    value = azurerm_subnet.subnet.name
  
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
  
}

output "nic" {
    value = azurerm_network_interface.nic.name
  
}

output "nic_id" {
    value = azurerm_network_interface.nic.id
  
}