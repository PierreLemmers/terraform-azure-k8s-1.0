variable "hosts" {
  type = map(object({
    name = string
    role = string
  }))
  description = "List of hosts to create"
}
variable "subnet_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}
variable "location" {}

variable "ssh_public_key" {
  type = string
}
