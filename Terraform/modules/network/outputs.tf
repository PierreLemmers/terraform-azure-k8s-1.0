output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "vnet" {
  value = azurerm_virtual_network.vnet.name
}
output "runner_subnet_id" {
  value = azurerm_subnet.runner_subnet.id
}
