terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create Storage Account in existing resource group
resource "azurerm_storage_account" "main" {
  name                      = lower(replace(var.storage_account_name, "-", ""))
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type

  https_traffic_only_enabled       = var.enable_https_traffic_only
  min_tls_version                  = var.minimum_tls_version
  access_tier                      = var.access_tier
  public_network_access_enabled    = var.enable_public_network_access
  shared_access_key_enabled        = var.enable_shared_access_key

  # Blob properties for soft delete
  blob_properties {
    change_feed_enabled = true
    
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }
    
    restore_policy {
      days = var.blob_restore_retention_days
    }
  }

  # Queue properties deprecated in newer provider versions

  tags = merge(
    var.tags,
    {
      "Tier" = var.account_tier
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}

# Create Blob Containers (if specified)
resource "azurerm_storage_container" "main" {
  for_each              = var.create_containers ? toset(var.container_names) : toset([])
  name                  = each.value
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.container_access_type

  depends_on = [azurerm_storage_account.main]
}

# Network Rules (if restricting access)
resource "azurerm_storage_account_network_rules" "main" {
  count                      = var.apply_network_rules ? 1 : 0
  storage_account_id         = azurerm_storage_account.main.id
  default_action             = var.network_default_action
  bypass                     = var.network_bypass
  virtual_network_subnet_ids = var.allowed_subnet_ids
  ip_rules                   = var.allowed_ip_ids

  depends_on = [azurerm_storage_account.main]
}

# Storage Account Encryption (Customer-managed keys - optional)
# Note: This requires key vault and identity setup outside this module
# resource "azurerm_storage_account_customer_managed_key" "main" {
#   count                     = var.enable_customer_managed_key ? 1 : 0
#   storage_account_id        = azurerm_storage_account.main.id
#   key_vault_key_id          = var.key_vault_key_id
#   user_assigned_identity_id = var.user_assigned_identity_id
#   depends_on                = [azurerm_storage_account.main]
# }

# Diagnostic Settings (if enabled)
resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_storage_account.main.name}"
  target_resource_id         = azurerm_storage_account.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Metrics for diagnostics
  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  depends_on = [azurerm_storage_account.main]
}
