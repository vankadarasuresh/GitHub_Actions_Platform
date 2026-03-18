output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.main.location
}

output "tags" {
  description = "Tags applied to the resource group"
  value       = azurerm_resource_group.main.tags
}
