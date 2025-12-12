variable "vm_count" {
  type        = number
  description = "Number of VMs to create"
}

variable "hosts" {
  type = map(object({
    name = string
    ip   = string
    role = string
  }))
  description = "List of hosts to create"
}

variable "subnet_id" {
  type = string
}

variable "resource_group_name" {}
variable "location" {}
variable "ssh_key" {
  type = string
}
variable "private_ip_address" {
}
