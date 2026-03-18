variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
  default     = "eastus"
  validation {
    condition     = length(var.location) > 0
    error_message = "Location cannot be empty."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90 && can(regex("^[a-zA-Z0-9.()-_]*[a-zA-Z0-9()]$", var.resource_group_name))
    error_message = "Resource group name must be 1-90 characters, alphanumeric and can contain hyphens, underscores, periods, and parentheses."
  }
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default = {
    "ManagedBy" = "Terraform"
  }
}
