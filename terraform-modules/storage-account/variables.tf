variable "resource_group_name" {
  description = "Name of the resource group (created by resource-group module)"
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1-90 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed (from resource-group module)"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique, 3-24 chars, lowercase)"
  type        = string
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3-24 characters."
  }
}

variable "account_tier" {
  description = "Storage Account Tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Replication type for storage account (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Valid replication types: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS"
  }
}

variable "access_tier" {
  description = "Access tier for blob storage (Hot, Cool, Archive)"
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool", "Archive"], var.access_tier)
    error_message = "Access tier must be Hot, Cool, or Archive."
  }
}

variable "enable_https_traffic_only" {
  description = "Enforce HTTPS traffic only"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version required"
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.minimum_tls_version)
    error_message = "Valid TLS versions: TLS1_0, TLS1_1, TLS1_2"
  }
}

variable "enable_public_network_access" {
  description = "Allow public network access"
  type        = bool
  default     = true
}

variable "enable_shared_access_key" {
  description = "Enable Shared Access Key based access"
  type        = bool
  default     = true
}

variable "apply_network_rules" {
  description = "Apply network restrictions"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "Default action for network rules (Allow or Deny)"
  type        = string
  default     = "Allow"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action must be Allow or Deny."
  }
}

variable "network_bypass" {
  description = "Bypass options for network rules"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access storage account"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ids" {
  description = "List of IP addresses/ranges allowed to access storage account"
  type        = list(string)
  default     = []
}

variable "blob_delete_retention_days" {
  description = "Number of days to retain deleted blobs"
  type        = number
  default     = 7
  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "Blob delete retention must be between 1-365 days."
  }
}

variable "blob_restore_retention_days" {
  description = "Number of days to retain blob restore capability"
  type        = number
  default     = 6
  validation {
    condition     = var.blob_restore_retention_days >= 0 && var.blob_restore_retention_days <= 365
    error_message = "Blob restore retention must be between 0-365 days."
  }
}

variable "enable_customer_managed_key" {
  description = "Enable customer-managed encryption key"
  type        = bool
  default     = false
}

variable "create_containers" {
  description = "Create blob containers"
  type        = bool
  default     = false
}

variable "container_names" {
  description = "List of blob container names to create"
  type        = list(string)
  default     = []
}

variable "container_access_type" {
  description = "Access type for blob containers (private, blob, container)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be private, blob, or container."
  }
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of Log Analytics workspace"
  type        = string
  default     = null
}

variable "diagnostics_retention_days" {
  description = "Number of days to retain diagnostics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
