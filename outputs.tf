output "resource_group_name" {
  value = azurerm_resource_group.aks_rg.name
}

output "vnet_name" {
  value = azurerm_virtual_network.aks_vnet.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}