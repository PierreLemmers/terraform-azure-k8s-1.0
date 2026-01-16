

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}

output "lan_cluster_nodes" {
  value = module.k8s_clusters["lan"].nodes
}

output "runner_cluster_nodes" {
  value = module.k8s_clusters["runner"].nodes
}
