# Azure Resource Group Terraform Module

Creates an Azure Resource Group with consistent tagging and configuration management.

## Overview

This module provides a foundational resource group that can be used by other infrastructure modules (Storage Account, Virtual Machines, Load Balancer, etc.). By centralizing resource group creation, you ensure:

- ✅ Consistent naming conventions across all resources
- ✅ Unified tagging strategy for cost allocation and organization
- ✅ Single point of lifecycle management
- ✅ Simplified dependencies for other modules

## Usage

### Basic Usage

```hcl
module "resource_group" {
  source = "../../platform/terraform-modules/resource-group"

  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Application = var.application_name
    Team        = var.team_name
    CostCenter  = var.cost_center
  }
}
```

### Development Environment

```hcl
module "dev_rg" {
  source = "../../platform/terraform-modules/resource-group"

  environment         = "dev"
  location            = "eastus"
  resource_group_name = "rg-myapp-dev"

  tags = {
    Environment = "development"
    Application = "myapp"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### Production Environment

```hcl
module "prod_rg" {
  source = "../../platform/terraform-modules/resource-group"

  environment         = "prod"
  location            = "eastus"
  resource_group_name = "rg-myapp-prod"

  tags = {
    Environment = "production"
    Application = "myapp"
    Team        = "platform"
    CostCenter  = "engineering"
    Backup      = "daily"
    DR          = "required"
  }
}
```

## Using with Other Modules

After creating the resource group, pass its outputs to other modules:

```hcl
# Create resource group
module "resource_group" {
  source = "../../platform/terraform-modules/resource-group"

  environment         = "prod"
  location            = "eastus"
  resource_group_name = "rg-myapp-prod"
  tags                = var.tags
}

# Create storage account in the resource group
module "storage" {
  source = "../../platform/terraform-modules/storage-account"

  # Pass resource group outputs to other modules
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags

  # Storage-specific configuration
  storage_account_name     = "stgmyappprod001"
  account_replication_type = "GRS"
}

# Create VMs in the same resource group
module "vms" {
  source = "../../platform/terraform-modules/virtual-machines"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags

  # VM-specific configuration
  vm_name_prefix = "vm-myapp-prod"
  vm_count       = 4
}

# Create load balancer in the same resource group
module "lb" {
  source = "../../platform/terraform-modules/load-balancer"

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags

  # LB-specific configuration
  loadbalancer_name = "lb-myapp-prod"
}
```

## Advantages of Separate Resource Group Module

### 1. Single Responsibility
- Resource group creation is isolated in its own module
- Easier to test and validate

### 2. Reusability
- Use same resource group for multiple infrastructure deployments
- Share tags and settings across organization

### 3. Lifecycle Management
- Create/destroy resource group independently
- Manage resource group lifecycle separately from resources

### 4. Tagging Consistency
- All resources inherit resource group tags
- Centralized tag management

### 5. Cost Tracking
- Easy to track costs per resource group
- Simplifies billing and cost allocation

### 6. Team Organization
- Each team can create their own resource groups
- Clear ownership and boundaries

## Input Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `environment` | string | - | Environment (dev, staging, prod) - Required |
| `location` | string | eastus | Azure region for resource group |
| `resource_group_name` | string | - | Resource group name (1-90 chars) - Required |
| `tags` | map(string) | `{"ManagedBy" = "Terraform"}` | Tags to apply to resource group |

### Variable Validation

- **environment**: Must be one of: dev, staging, prod
- **location**: Must not be empty
- **resource_group_name**: Must be 1-90 characters, alphanumeric with hyphens, underscores, periods, and parentheses

## Output Values

| Output | Description |
|--------|-------------|
| `resource_group_id` | Full resource ID of the resource group |
| `resource_group_name` | Name of the resource group |
| `location` | Location of the resource group |
| `tags` | Tags applied to the resource group |

## Module Dependencies

This module depends on:
- Azure Provider (v3.0+)
- Terraform (v1.0+)

## Lifecycle Management

The module respects the `LastModified` tag by ignoring changes to it in the `lifecycle` block. This prevents Terraform from detecting drift when the tag is manually updated by operational tools.

```hcl
lifecycle {
  ignore_changes = [tags["LastModified"]]
}
```

## Best Practices

### 1. Naming Conventions
Use consistent naming patterns:
```
rg-{application}-{environment}
rg-myapp-dev
rg-myapp-staging
rg-myapp-prod
```

### 2. Tagging Strategy
Apply standardized tags:
```hcl
tags = {
  Environment = "production"
  Application = "myapp"
  Team        = "platform"
  CostCenter  = "engineering"
  Owner       = "platform-team"
  Backup      = "daily"           # if applicable
  DR          = "required"        # if applicable
}
```

### 3. Environment Separation
Create separate resource groups per environment:
- `rg-myapp-dev` for development
- `rg-myapp-staging` for staging
- `rg-myapp-prod` for production

### 4. Regional Placement
Choose appropriate region:
- `eastus` for US-based deployments
- `westeurope` for EU-based deployments
- `eastasia` for Asia-Pacific deployments

## Common Patterns

### Multi-Environment Setup

```hcl
# Create resource groups for all environments
locals {
  environments = {
    dev = {
      location = "eastus"
      tags = {
        Environment = "development"
      }
    }
    staging = {
      location = "eastus"
      tags = {
        Environment = "staging"
      }
    }
    prod = {
      location = "eastus"
      tags = {
        Environment = "production"
      }
    }
  }
}

module "resource_groups" {
  for_each = local.environments

  source = "../../platform/terraform-modules/resource-group"

  environment         = each.key
  location            = each.value.location
  resource_group_name = "rg-myapp-${each.key}"
  tags                = each.value.tags
}
```

### Using Outputs in Other Modules

```hcl
module "storage" {
  source = "../../platform/terraform-modules/storage-account"

  # Reference resource group outputs
  resource_group_name = module.resource_groups["prod"].resource_group_name
  location            = module.resource_groups["prod"].location
  tags                = module.resource_groups["prod"].tags

  # Other configuration...
}
```

## Troubleshooting

### Issue: Resource Group Already Exists
**Problem:** Another deployment or manual creation created the resource group
**Solution:** 
```bash
# Import into Terraform state
terraform import azurerm_resource_group.main /subscriptions/{subscriptionId}/resourceGroups/{rgName}
```

### Issue: Invalid Resource Group Name
**Problem:** Name contains invalid characters
**Solution:** Ensure name matches pattern: alphanumeric, hyphens, underscores, periods, parentheses (1-90 chars)

### Issue: Location Not Found
**Problem:** Specified region doesn't exist or isn't available
**Solution:** Use valid Azure region:
```bash
az account list-locations --query "[].name" -o tsv
```

### Issue: Insufficient Permissions
**Problem:** Service principal lacks permissions to create resource groups
**Solution:** Ensure service principal has "Contributor" or "Owner" role at subscription level

## Examples

### Minimal Configuration
```hcl
module "rg" {
  source = "../../platform/terraform-modules/resource-group"

  environment         = "dev"
  resource_group_name = "rg-test-dev"
}
```

### Full Configuration
```hcl
module "rg" {
  source = "../../platform/terraform-modules/resource-group"

  environment         = "prod"
  location            = "westeurope"
  resource_group_name = "rg-myapp-prod"

  tags = {
    Environment  = "production"
    Application  = "myapp"
    Team         = "platform"
    CostCenter   = "engineering"
    Owner        = "platform-team@example.com"
    Backup       = "daily"
    DR           = "required"
    Compliance   = "SOC2"
    CreatedDate  = "2024-01-15"
  }
}
```

## See Also

- [Storage Account Module](../storage-account/README.md)
- [Virtual Machines Module](../virtual-machines/README.md)
- [Load Balancer Module](../load-balancer/README.md)
- [Azure Resource Group Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
