# VNet para Compute
resource "azurerm_virtual_network" "compute" {
  name                = var.vnet_compute_name
  address_space       = [var.vnet_compute_cidr]
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "db" {
  name                 = var.subnet_db_name
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.compute.name
  address_prefixes     = [var.subnet_db_cidr]
}

# VNet para AKS
resource "azurerm_virtual_network" "aks" {
  name                = var.vnet_aks_name
  address_space       = [var.vnet_aks_cidr]
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "aks" {
  name                 = var.subnet_aks_name
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.subnet_aks_cidr]
}
