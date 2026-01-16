locals {
  rendered_cloudinit = templatefile("${path.module}/templates/cloud-init.yml.tpl", {
    hostname       = var.hostname != "" ? var.hostname : var.name
    role           = var.role
    admin_username = var.admin_username
    ssh_public_key = var.ssh_public_key

    # Only used for ansible VM in your lab
    ssh_private_key = var.ssh_private_key

    create_ansible_user = var.create_ansible_user
    install_ansible     = var.install_ansible_tools
    extra_packages      = var.extra_packages

    git_repo_url    = var.git_repo_url
    git_repo_branch = var.git_repo_branch
    git_dest_dir    = var.git_dest_dir
  })
}


resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
  }

  tags = var.tags
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  # Always base64 if set; module will provide a default rendered cloud-init
  custom_data = base64encode(local.rendered_cloudinit)

  admin_ssh_key {
    username   = var.admin_username
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

  tags = merge(var.tags, {
    role = var.role
  })
}
