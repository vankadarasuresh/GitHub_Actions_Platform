output "storage_account_id" {
  description = "The ID of the created Storage Account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "The name of the created Storage Account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_location" {
  description = "The primary location of the Storage Account"
  value       = azurerm_storage_account.main.primary_location
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the Storage Account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "storage_account_secondary_connection_string" {
  description = "The secondary connection string (for GRS/RAGRS)"
  value       = try(azurerm_storage_account.main.secondary_connection_string, null)
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_account_secondary_blob_endpoint" {
  description = "The secondary blob endpoint URL (for GRS/RAGRS)"
  value       = try(azurerm_storage_account.main.secondary_blob_endpoint, null)
}

output "storage_account_primary_file_endpoint" {
  description = "The primary file endpoint URL"
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "The primary queue endpoint URL"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "storage_account_primary_table_endpoint" {
  description = "The primary table endpoint URL"
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "storage_account_primary_web_endpoint" {
  description = "The primary web endpoint URL (static website)"
  value       = try(azurerm_storage_account.main.primary_web_endpoint, null)
}

output "storage_account_access_key" {
  description = "The primary access key for the Storage Account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "storage_account_secondary_access_key" {
  description = "The secondary access key for the Storage Account"
  value       = try(azurerm_storage_account.main.secondary_access_key, null)
  sensitive   = true
}

output "container_ids" {
  description = "IDs of created blob containers"
  value       = { for name, container in azurerm_storage_container.main : name => container.id }
}

output "container_names" {
  description = "Names of created blob containers"
  value       = { for name, container in azurerm_storage_container.main : name => container.name }
}
