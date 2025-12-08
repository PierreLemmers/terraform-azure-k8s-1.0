variable "subnet_id" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "location" {}
variable "ssh_key" {
  type = string
}
variable "hosts" {
  type = map(object({
    name = string
    ip   = string
    role = string
  }))
  description = "List of hosts to create"
}
