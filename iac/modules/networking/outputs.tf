output "vnet_compute_id" { value = azurerm_virtual_network.compute.id }
output "vnet_aks_id"     { value = azurerm_virtual_network.aks.id }

output "subnet_db_id"  { value = azurerm_subnet.db.id }
output "subnet_aks_id" { value = azurerm_subnet.aks.id }