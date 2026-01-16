locals {
  k8s_hosts = {
    for k, v in var.hosts :
    k => v
    if v.role == "k8s-control" || v.role == "k8s-worker"
  }

  cloudinit = {
    for k, v in local.k8s_hosts :
    k => templatefile("${path.module}/templates/cloud-init.yml.tpl", {
      hostname       = v.name
      role           = v.role
      cluster_name   = var.cluster_name
      ssh_public_key = var.ssh_public_key
    })
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
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  custom_data         = base64encode(local.cloudinit[each.key])
  network_interface_ids = [
    azurerm_network_interface.k8s[each.key].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
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
