output "peering_compute_to_aks_id" { value = azurerm_virtual_network_peering.compute_to_aks.id }
output "peering_aks_to_compute_id" { value = azurerm_virtual_network_peering.aks_to_compute.id }