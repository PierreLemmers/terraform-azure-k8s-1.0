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


provider "azuread" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
# rbac.tf
data "azuread_user" "me" {
  user_principal_name = "pierre.lemmers@cinqict.nl" # e.g. pierre@company.com
}

resource "azurerm_role_assignment" "me_owner_rg" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_user.me.object_id
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
  for_each            = var.clusters
  source              = "./modules/k8s"
  resource_group_name = var.resource_group_name
  location            = var.location
  ssh_public_key      = tls_private_key.lab.public_key_openssh
  admin_username      = "ansible"
  subnet_id           = local.subnet_ids[each.value.subnet]
  hosts               = each.value.nodes
  cluster_name        = each.key
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
  ssh_public_key      = tls_private_key.lab.public_key_openssh
  ssh_private_key_b64 = base64encode(tls_private_key.lab.private_key_openssh)
  admin_username      = "ansible"
  create_ansible_user = false
  inventory_yaml      = local.inventory_yaml

  # lab: allow ansible to SSH out using the same keypair


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
  ssh_public_key      = tls_private_key.lab.public_key_openssh
  admin_username      = "ansible"



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
  ssh_public_key      = tls_private_key.lab.public_key_openssh
  admin_username      = "ansible"


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
  ssh_public_key      = tls_private_key.lab.public_key_openssh
  admin_username      = "ansible"

  tags = {
    env = "lab"
  }
}
