output "private_ips" {
  value = {
    for k, nic in azurerm_network_interface.k8s :
    k => nic.private_ip_address
  }
}

output "nodes" {
  value = {
    for k, v in local.k8s_hosts :
    k => {
      name = v.name
      ip   = v.ip
      role = v.role
    }
  }
}

output "node_info" {
  value = {
    for k, nic in azurerm_network_interface.k8s :
    k => {
      name = k
      ip   = nic.ip_configuration[0].private_ip_address
    }
  }
}
