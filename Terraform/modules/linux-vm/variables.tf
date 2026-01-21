variable "hostname" {
  type        = string
  description = "Hostname for cloud-init. Defaults to var.name if empty."
  default     = ""
}

variable "create_ansible_user" {
  type        = bool
  description = "Create an 'ansible' user with sudo and SSH key"
  default     = true
}

variable "install_ansible_tools" {
  type        = bool
  description = "Install ansible tooling on the VM (useful for the Ansible control node only)"
  default     = false
}

variable "extra_packages" {
  type        = list(string)
  description = "Extra packages to install via cloud-init"
  default     = []
}

# Keep your existing custom_data variable (important for backward compatibility)
variable "custom_data" {
  type        = string
  description = "Optional raw cloud-init. If empty, module renders its own template."
  default     = ""
}


variable "name" {
  type = string
}

variable "role" {
  type        = string
  description = "Role label used for cloud-init conditional logic or Ansible grouping."
  default     = ""
}

variable "private_ip" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "ansible"
}

variable "ssh_public_key" {
  type = string
}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "git_repo_url" {
  type        = string
  description = "Public Git repository to clone on first boot"
  default     = ""
}

variable "git_repo_branch" {
  type        = string
  description = "Git branch to checkout"
  default     = "main"
}

variable "git_dest_dir" {
  type        = string
  description = "Destination directory for the cloned repository"
  default     = "/home/ansible/projects"
}
variable "inventory_yaml" {
  type    = string
  default = ""
}

variable "ssh_private_key_b64" {
  type      = string
  default   = ""
  sensitive = true
}
