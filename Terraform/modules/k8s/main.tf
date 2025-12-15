locals {
  k8s_hosts = {
    for k, v in var.hosts :
    k => v
    if v.role == "k8s-control" || v.role == "k8s-worker"
  }
}


resource "azurerm_network_interface" "k8s" {
  for_each            = local.k8s_hosts
  name                = "${each.key}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = local.k8s_hosts
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.k8s[each.key].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/azureuser/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
