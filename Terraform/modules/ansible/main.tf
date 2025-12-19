locals {
  cloudinit = templatefile("${path.module}/cloud-init.yml.tpl", {
    hostname        = var.hosts["ansible"].name
    ssh_public_key  = var.ssh_public_key
    ssh_private_key = var.ssh_private_key
  })
}

resource "azurerm_network_interface" "ansible" {
  name                = "eth0"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.hosts["ansible"].ip
  }
}

resource "azurerm_linux_virtual_machine" "ansible-server" {
  name                = "ansible-server-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "azureuser"
  custom_data         = base64encode(local.cloudinit)
  network_interface_ids = [
    azurerm_network_interface.ansible.id,
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
