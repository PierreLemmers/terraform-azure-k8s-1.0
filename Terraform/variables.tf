variable "vm_count" {
  type        = number
  description = "Number of VMs to create"
}

variable "hosts" {
  type = map(object({
    name    = string
    ip      = string
    role    = string
    cluster = string
  }))
  description = "List of hosts to create"
}


variable "subnet_id" {
  type = string
}

variable "resource_group_name" {}
variable "location" {}

variable "clusters" {
  description = "Cluster definitions. Each cluster has a subnet key and a set of node host records."
  type = map(object({
    subnet = string
    nodes = map(object({
      ip      = string
      role    = string
      name    = string
      cluster = string
    }))
  }))
}

variable "vnet_name" { type = string }
variable "vnet_cidr" { type = string }

variable "lan_subnet_cidr" { type = string }
variable "runner_subnet_cidr" { type = string }
variable "dmz_subnet_cidr" { type = string }

variable "enable_bastion" { type = bool }
variable "bastion_subnet_cidr" { type = string }
