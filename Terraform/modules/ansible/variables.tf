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
    name    = string
    ip      = string
    role    = string
    cluster = string
  }))
  description = "List of hosts to create"
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
