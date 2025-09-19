resource "azurerm_virtual_network_peering" "compute_to_aks" {
  name                      = "peer-compute-to-aks"
  resource_group_name       = var.resource_group
  virtual_network_name      = basename(var.vnet_compute_id)
  remote_virtual_network_id = var.vnet_aks_id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "aks_to_compute" {
  name                      = "peer-aks-to-compute"
  resource_group_name       = var.resource_group
  virtual_network_name      = basename(var.vnet_aks_id)
  remote_virtual_network_id = var.vnet_compute_id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}
