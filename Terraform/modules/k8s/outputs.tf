output "private_ips" {
  value = {
    for k, nic in azurerm_network_interface.k8s :
    k => nic.private_ip_address
  }
}
