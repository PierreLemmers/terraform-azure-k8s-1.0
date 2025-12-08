resource "azurerm_network_interface" "ansible" {
  name                = "eth0"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "ansible-server" {
  name                = "ansible-server-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "root"
  network_interface_ids = [
    azurerm_network_interface.ansible.id,
  ]
  admin_ssh_key {
    username   = "root"
    public_key = file("~/.ssh/id_rsa.pub")
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
