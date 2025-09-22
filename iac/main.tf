data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

module "networking" {
  source            = "./modules/networking"
  location          = var.location
  resource_group    = data.azurerm_resource_group.rg.name
  vnet_compute_name = var.vnet_compute_name
  vnet_compute_cidr = var.vnet_compute_cidr
  subnet_db_name    = var.subnet_db_name
  subnet_db_cidr    = var.subnet_db_cidr
  vnet_aks_name     = var.vnet_aks_name
  vnet_aks_cidr     = var.vnet_aks_cidr
  subnet_aks_name   = var.subnet_aks_name
  subnet_aks_cidr   = var.subnet_aks_cidr
}

module "peering" {
  source          = "./modules/peering"
  resource_group  = data.azurerm_resource_group.rg.name
  vnet_compute_id = module.networking.vnet_compute_id
  vnet_aks_id     = module.networking.vnet_aks_id
}

module "compute" {
  source         = "./modules/compute"
  location       = var.location
  resource_group = data.azurerm_resource_group.rg.name
  subnet_db_id   = module.networking.subnet_db_id
  vm_db_name     = var.vm_db_name
  vm_bkp_name    = var.vm_bkp_name
  admin_user     = var.vm_admin_user
  ssh_public_key = var.ssh_public_key
}

module "aks" {
  source         = "./modules/aks"
  location       = var.location
  resource_group = data.azurerm_resource_group.rg.name
  cluster_name   = var.aks_name
  node_count     = var.aks_node_count
  node_vm_size   = var.aks_node_vm_size
  subnet_aks_id  = module.networking.subnet_aks_id
}