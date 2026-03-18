terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    {
      "Type" = "Network"
    }
  )
}

# Create Subnets
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes

  service_endpoints = var.service_endpoints
}

# Create Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.environment}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Default rules
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create Network Interfaces
resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.network_interface_name_prefix}-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = var.private_ip_address_allocation
    public_ip_address_id          = var.create_public_ips ? azurerm_public_ip.main[count.index].id : null
    primary                       = true
  }

  tags = merge(
    var.tags,
    {
      "Type" = "NetworkInterface"
    }
  )
}

# Create Public IPs (optional)
resource "azurerm_public_ip" "main" {
  count               = var.create_public_ips ? var.vm_count : 0
  name                = "pip-vm-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = merge(
    var.tags,
    {
      "Type" = "PublicIP"
    }
  )
}

# Public IP Addresses and Network Interface associations are configured
# Network interfaces with static private IPs are created above
# Public IPs (if enabled) are associated during NIC creation via IP configurations

# Create Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.vm_name_prefix}-${count.index + 1}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id
  ]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
    write_accelerator_enabled = var.os_disk_write_accelerator_enabled
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  # Admin SSH Keys
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  computer_name = "${var.vm_name_prefix}${count.index + 1}"

  # Custom Data (bootstrap script)
  custom_data = var.custom_data != null ? base64encode(var.custom_data) : null

  # Enable system-assigned managed identity
  identity {
    type         = var.enable_system_managed_identity ? "SystemAssigned" : null
    identity_ids = var.enable_user_managed_identity ? var.user_managed_identity_ids : null
  }

  tags = merge(
    var.tags,
    {
      "Type" = "VirtualMachine"
      "Index" = count.index + 1
    }
  )

  depends_on = [azurerm_network_interface.main]
}

# Virtual Machine Extensions (optional)
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count                      = var.enable_azure_monitor_agent ? var.vm_count : 0
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}

# OS Disk Encryption is handled at the VM level with os_disk configuration
# For advanced encryption set scenarios, configure key vault separately
