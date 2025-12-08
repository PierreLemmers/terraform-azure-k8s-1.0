data "template_file" "cloudinit_render" {
  for_each = { for k, v in var.hosts : k => v }
  template = file("${path.module}/cloud-init.yml.tpl")

  vars = {
    hostname = each.key
    ssh_key  = file("~/.ssh/id_rsa.pub")
    role     = each.value.role
  }
}
