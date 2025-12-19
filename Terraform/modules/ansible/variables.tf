variable "subnet_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}
variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key" {
  type      = string
  sensitive = true
}
variable "location" {}

variable "hosts" {
  type = map(object({
    name = string
    ip   = string
    role = string
  }))
  description = "List of hosts to create"
}
