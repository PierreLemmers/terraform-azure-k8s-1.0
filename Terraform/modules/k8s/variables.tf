
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

variable "hosts" {
  description = "Hosts for this specific cluster instance"
  type = map(object({
    ip      = string
    role    = string
    name    = string
    cluster = string
  }))
}


variable "cluster_name" {
  type    = string
  default = "cluster"
}
variable "admin_username" {
  type    = string
  default = "ansible"
}
