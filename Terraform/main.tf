# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "harbor-vm" {
  source              = "./modules/harbor-vm"
  subnet_id           = module.network.subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  hosts               = var.hosts
  ssh_public_key      = tls_private_key.ansible.public_key_openssh
}

module "gitlab-vm" {
  source              = "./modules/harbor-vm"
  subnet_id           = module.network.subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  hosts               = var.hosts
  ssh_public_key      = tls_private_key.ansible.public_key_openssh
}

module "k8s" {
  source              = "./modules/k8s"
  subnet_id           = module.network.subnet_id
  hosts               = var.hosts
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh
}

module "k8s-runners" {
  source              = "./modules/k8s"
  hosts               = var.runner_hosts
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh
  subnet_id           = module.network.runner_subnet_id
}

module "ansible" {
  source              = "./modules/ansible"
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh
  ssh_private_key     = tls_private_key.ansible.private_key_pem
  subnet_id           = module.network.subnet_id
  hosts               = var.hosts
}

module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
}
