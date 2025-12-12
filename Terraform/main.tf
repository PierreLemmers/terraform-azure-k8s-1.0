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


module "k8s" {
  source              = "./modules/k8s"
  subnet_id           = module.network.subnet_id
  hosts               = var.hosts
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "ansible" {
  source              = "./modules/ansible"
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_key             = var.ssh_key
  subnet_id           = module.network.subnet_id
  hosts               = var.hosts
  private_ip_address  = var.private_ip_address
}

module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
}
