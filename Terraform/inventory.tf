locals {
  inventory_yaml = templatefile("${path.root}/inventory.yml.tpl", {
    hosts    = var.hosts
    clusters = var.clusters
  })
}

resource "local_file" "inventory" {
  filename = "${path.root}/generated/inventory.yml"
  content  = local.inventory_yaml
}
