# General
variable "location" { type = string }
variable "rg_name" { type = string }

# Compute VNet
variable "vnet_compute_name" { type = string }
variable "vnet_compute_cidr" { type = string }
variable "subnet_db_name" { type = string }
variable "subnet_db_cidr" { type = string }

# AKS VNet
variable "vnet_aks_name" { type = string }
variable "vnet_aks_cidr" { type = string }
variable "subnet_aks_name" { type = string }
variable "subnet_aks_cidr" { type = string }

# VMs
variable "vm_db_name" { type = string }
variable "vm_bkp_name" { type = string }
variable "vm_admin_user" { type = string }
variable "ssh_public_key" { type = string }

# AKS
variable "aks_name" { type = string }
variable "aks_node_count" { type = number }
variable "aks_node_vm_size" { type = string }


