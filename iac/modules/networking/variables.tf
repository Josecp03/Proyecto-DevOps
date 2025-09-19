variable "location"          { type = string }
variable "resource_group"    { type = string }

variable "vnet_compute_name" { type = string }
variable "vnet_compute_cidr" { type = string }
variable "subnet_db_name"    { type = string }
variable "subnet_db_cidr"    { type = string }

variable "vnet_aks_name"     { type = string }
variable "vnet_aks_cidr"     { type = string }
variable "subnet_aks_name"   { type = string }
variable "subnet_aks_cidr"   { type = string }
