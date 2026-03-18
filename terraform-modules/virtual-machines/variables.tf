variable "resource_group_name" {
  description = "Name of the resource group (created by resource-group module)"
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1-90 characters."
  }
}

variable "location" {
  description = "Azure region for resources (from resource-group module)"
  type        = string
}

variable "environment" {
  description = "Environment name for naming resources (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "service_endpoints" {
  description = "Service endpoints to enable on subnet"
  type        = list(string)
  default     = []
}

variable "vm_count" {
  description = "Number of virtual machines to create"
  type        = number
  default     = 2
  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 100
    error_message = "VM count must be between 1-100."
  }
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (SKU)"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for admin user"
  type        = string
  sensitive   = true
}

variable "disable_password_authentication" {
  description = "Disable password authentication (use SSH keys)"
  type        = bool
  default     = true
}

variable "image_publisher" {
  description = "Image publisher (e.g., Canonical, MicrosoftWindowsServer)"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image offer name"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
  default     = "20_04-lts-gen2"
}

variable "image_version" {
  description = "Image version (use 'latest' for current version)"
  type        = string
  default     = "latest"
}

variable "os_disk_caching" {
  description = "OS disk caching type (ReadOnly, ReadWrite, None)"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage type (Standard_LRS, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS)"
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 1023
    error_message = "OS disk size must be between 30-1023 GB."
  }
}

variable "os_disk_write_accelerator_enabled" {
  description = "Enable write accelerator on OS disk"
  type        = bool
  default     = false
}

variable "network_interface_name_prefix" {
  description = "Prefix for network interface names"
  type        = string
}

variable "private_ip_address_allocation" {
  description = "Private IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Dynamic"
}

variable "create_public_ips" {
  description = "Create public IP addresses for VMs"
  type        = bool
  default     = true
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "Public IP SKU (Basic or Standard)"
  type        = string
  default     = "Standard"
}

variable "ssh_source_address_prefix" {
  description = "Allow SSH from this address/prefix (default: 0.0.0.0/0 - restrict in prod!)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "custom_data" {
  description = "Custom data script to run on VM initialization"
  type        = string
  default     = null
}

variable "enable_system_managed_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = true
}

variable "enable_user_managed_identity" {
  description = "Enable user-assigned managed identity"
  type        = bool
  default     = false
}

variable "user_managed_identity_ids" {
  description = "List of user-assigned managed identity IDs"
  type        = list(string)
  default     = []
}

variable "enable_azure_monitor_agent" {
  description = "Install Azure Monitor Agent extension"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
