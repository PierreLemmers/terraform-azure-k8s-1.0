variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "carwash-vnet"
}

variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "lan_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "runner_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "dmz_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

# Where YOU (admin) can manage from (your public IP / corporate range)
variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to SSH/admin into VMs (e.g., your public IP /32)."
  default     = "0.0.0.0/0" # tighten for real use
}

# If you want Bastion (recommended) to avoid public IPs on VMs:
variable "enable_bastion" {
  type    = bool
  default = false
}

# Bastion requires a dedicated subnet named 'AzureBastionSubnet' (at least /27 recommended)
variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.250.0/27"
}
