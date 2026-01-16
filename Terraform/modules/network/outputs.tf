output "lan_subnet_id" {
  value = azurerm_subnet.lan.id
}

output "runner_subnet_id" {
  value = azurerm_subnet.runners.id
}

output "dmz_subnet_id" {
  value = azurerm_subnet.dmz.id
}
