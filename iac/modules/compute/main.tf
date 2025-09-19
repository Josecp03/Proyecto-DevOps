# NSG para VM Backup (acceso público)
resource "azurerm_network_security_group" "bkp_nsg" {
  name                = "nsg-${var.vm_bkp_name}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "Allow-SSH-External"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Development"
    Purpose     = "Backup-VM-Access"
  }
}

# NSG para VM Database (solo interno)
resource "azurerm_network_security_group" "db_nsg" {
  name                = "nsg-${var.vm_db_name}"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "Allow-SSH-Internal"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-MySQL"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-PostgreSQL"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Development"
    Purpose     = "Database-VM-Internal"
  }
}

# IP pública para VM Backup
resource "azurerm_public_ip" "bkp" {
  name                = "${var.vm_bkp_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NIC Database (solo privada)
resource "azurerm_network_interface" "db" {
  name                = "${var.vm_db_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_db_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
  }
}

# NIC Backup (pública + privada)
resource "azurerm_network_interface" "bkp" {
  name                = "${var.vm_bkp_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_db_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bkp.id
  }
}

# Asociaciones NSG
resource "azurerm_network_interface_security_group_association" "db_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.db.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_network_interface_security_group_association" "bkp_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.bkp.id
  network_security_group_id = azurerm_network_security_group.bkp_nsg.id
}

# VM Database
resource "azurerm_linux_virtual_machine" "db" {
  name                   = var.vm_db_name
  location               = var.location
  resource_group_name    = var.resource_group
  size                   = "Standard_B2s"
  admin_username         = var.admin_user
  network_interface_ids  = [azurerm_network_interface.db.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.ssh_public_key
  }

  depends_on = [azurerm_network_interface_security_group_association.db_nsg_assoc]
}

# VM Backup
resource "azurerm_linux_virtual_machine" "bkp" {
  name                   = var.vm_bkp_name
  location               = var.location
  resource_group_name    = var.resource_group
  size                   = "Standard_B2s"
  admin_username         = var.admin_user
  network_interface_ids  = [azurerm_network_interface.bkp.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.ssh_public_key
  }

  depends_on = [azurerm_network_interface_security_group_association.bkp_nsg_assoc]
}

# Generar archivo de configuración SSH
resource "local_file" "ssh_config" {
  content = <<EOT
Host vm-bkp
  HostName ${azurerm_public_ip.bkp.ip_address}
  User ${var.admin_user}
  IdentityFile ~/.ssh/id_rsa

Host vm-db
  HostName ${azurerm_linux_virtual_machine.db.private_ip_address}
  User ${var.admin_user}
  ProxyJump vm-bkp
  IdentityFile ~/.ssh/id_rsa
EOT

  filename = "/home/${var.admin_user}/.ssh/config"
}
