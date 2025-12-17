data "template_file" "cloudinit_render" {
  for_each = { for k, v in var.hosts : k => v }
  template = file("${path.module}/templates/cloud-init.yml.tpl")

  vars = {
    hostname = each.key
    ssh_key  = var.ssh_public_key
    role     = each.value.role
  }
}

data "template_file" "ansible_inventory" {
  template = file("${path.module}/templates/inventory.yml.tpl")

  vars = {
    inventory_content = data.template_file.inventory.rendered
  }
}
