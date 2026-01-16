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



module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_cidr           = var.vnet_cidr
  lan_subnet_cidr     = var.lan_subnet_cidr
  runner_subnet_cidr  = var.runner_subnet_cidr
  dmz_subnet_cidr     = var.dmz_subnet_cidr
  enable_bastion      = var.enable_bastion
  bastion_subnet_cidr = var.bastion_subnet_cidr
}

locals {
  subnet_ids = {
    lan     = module.network.lan_subnet_id
    runners = module.network.runner_subnet_id
    dmz     = module.network.dmz_subnet_id
  }
}

module "k8s_clusters" {
  for_each = var.clusters
  source   = "./modules/k8s"

  resource_group_name = var.resource_group_name
  location            = var.location

  subnet_id      = local.subnet_ids[each.value.subnet]
  hosts          = each.value.nodes
  ssh_public_key = tls_private_key.ansible.public_key_openssh
  cluster_name   = each.key
}


module "ansible_vm" {
  source              = "./modules/linux-vm"
  name                = var.hosts["ansible"].name
  hostname            = var.hosts["ansible"].name
  role                = var.hosts["ansible"].role
  private_ip          = var.hosts["ansible"].ip
  subnet_id           = module.network.lan_subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh

  # lab: allow ansible to SSH out using the same keypair
  ssh_private_key = tls_private_key.ansible.private_key_pem

  install_ansible_tools = true
  extra_packages        = ["jq", "curl"]

  git_repo_url    = "https://github.com/PierreLemmers/terraform-azure-k8s-1.0.git"
  git_repo_branch = "main"
  git_dest_dir    = "/home/ansible/projects"

  tags = { env = "lab" }
}



module "harbor_dmz" {
  source              = "./modules/linux-vm"
  name                = var.hosts["harbor-dmz"].name
  hostname            = var.hosts["harbor-dmz"].name
  role                = var.hosts["harbor-dmz"].role
  private_ip          = var.hosts["harbor-dmz"].ip
  subnet_id           = module.network.dmz_subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh

  # Let the module render cloud-init
  # custom_data removed

  tags = {
    env = "lab"
  }
}


module "harbor_lan" {
  source              = "./modules/linux-vm"
  name                = var.hosts["harbor-lan"].name
  hostname            = var.hosts["harbor-lan"].name
  role                = var.hosts["harbor-lan"].role
  private_ip          = var.hosts["harbor-lan"].ip
  subnet_id           = module.network.lan_subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh

  tags = {
    env = "lab"
  }
}


module "gitlab" {
  source              = "./modules/linux-vm"
  name                = var.hosts["gitlab"].name
  hostname            = var.hosts["gitlab"].name
  role                = var.hosts["gitlab"].role
  private_ip          = var.hosts["gitlab"].ip
  subnet_id           = module.network.lan_subnet_id
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.ansible.public_key_openssh

  tags = {
    env = "lab"
  }
}
