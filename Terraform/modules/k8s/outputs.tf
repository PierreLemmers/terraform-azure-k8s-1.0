output "private_ips" {
  value = azurerm_network_interface.k8s[*].ip_configuration[0].private_ip_address
}
