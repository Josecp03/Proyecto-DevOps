output "vm_db_private_ip"  { value = azurerm_network_interface.db.private_ip_address }
output "vm_bkp_private_ip" { value = azurerm_network_interface.bkp.private_ip_address }
output "vm_bkp_public_ip"  { value = azurerm_public_ip.bkp.ip_address }
output "db_nsg_id"         { value = azurerm_network_security_group.db_nsg.id }
output "bkp_nsg_id"        { value = azurerm_network_security_group.bkp_nsg.id }
