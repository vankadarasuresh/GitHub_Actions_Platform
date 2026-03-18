# Azure Storage Account Terraform Module

Production-ready Terraform module for deploying Azure Storage Accounts with comprehensive security and compliance features.

## Features

✅ **Security**
- HTTPS-only traffic enforcement
- Configurable TLS minimum version
- Soft delete for blobs (data protection)
- Optional customer-managed encryption keys
- Network rules and IP whitelisting

✅ **High Availability**
- Multiple replication options (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)
- Geo-redundancy support
- Read-only secondary endpoints

✅ **Compliance & Monitoring**
- Automatic diagnostic settings
- Blob and queue logging
- Azure Monitor integration
- Environment-based tagging

✅ **Flexibility**
- Multiple access tiers (Hot, Cool, Archive)
- Optional blob container creation
- Configurable retention policies
- Support for Standard and Premium tiers

## Usage

### Basic Example

```hcl
module "storage_account" {
  source = "./terraform-modules/storage-account"

  environment              = "prod"
  location                 = "eastus"
  resource_group_name      = "rg-myapp-prod"
  storage_account_name     = "stgmyappprod001"
  
  account_tier             = "Standard"
  account_replication_type = "GRS"  # Geo-redundant for HA
  
  enable_https_traffic_only = true
  minimum_tls_version       = "TLS1_2"
  
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### With Containers and Diagnostics

```hcl
module "storage_account" {
  source = "./terraform-modules/storage-account"

  environment              = "prod"
  resource_group_name      = "rg-myapp-prod"
  storage_account_name     = "stgmyappprod001"
  
  # Create containers
  create_containers    = true
  container_names      = ["backups", "logs", "data"]
  container_access_type = "private"
  
  # Enable diagnostics
  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostics_retention_days = 90
  
  tags = var.tags
}
```

### With Network Restrictions

```hcl
module "storage_account" {
  source = "./terraform-modules/storage-account"

  environment              = "prod"
  resource_group_name      = "rg-myapp-prod"
  storage_account_name     = "stgmyappprod001"
  
  # Restrict network access
  apply_network_rules       = true
  network_default_action    = "Deny"
  network_bypass            = ["AzureServices"]
  allowed_subnet_ids        = [azurerm_subnet.main.id]
  allowed_ip_ids            = ["203.0.113.0/24"]
  
  tags = var.tags
}
```

## Variables

### Required
- `environment` - Environment name (dev, staging, prod)
- `resource_group_name` - Name of resource group
- `storage_account_name` - Name of storage account (3-24 chars, lowercase)

### Optional
- `location` - Azure region (default: eastus)
- `account_tier` - Standard or Premium (default: Standard)
- `account_replication_type` - LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS (default: LRS)
- `access_tier` - Hot, Cool, Archive (default: Hot)
- `enable_https_traffic_only` - Enforce HTTPS (default: true)
- `minimum_tls_version` - TLS1_0, TLS1_1, TLS1_2 (default: TLS1_2)

See `variables.tf` for complete list.

## Outputs

```hcl
# Core outputs
storage_account_id                          # Storage account resource ID
storage_account_name                        # Storage account name
storage_account_primary_connection_string   # Connection string (sensitive)
storage_account_primary_blob_endpoint       # Blob service endpoint
storage_account_access_key                  # Primary access key (sensitive)

# Additional endpoints
storage_account_primary_file_endpoint       # File service endpoint
storage_account_primary_queue_endpoint      # Queue service endpoint
storage_account_primary_table_endpoint      # Table service endpoint

# Container outputs
container_ids                               # Created container IDs
container_names                             # Created container names
```

## Best Practices Implemented

1. **Security**
   - HTTPS enforcement by default
   - TLS 1.2+ required
   - Sensitive outputs marked
   - Network rules support

2. **Data Protection**
   - Soft delete retention configured
   - Configurable restore retention
   - Queue logging enabled

3. **Compliance**
   - Automatic tagging
   - Diagnostic logging
   - Storage account lifecycle management

4. **Flexibility**
   - Support for multiple replication types
   - Multiple access tiers
   - Optional containers creation

## Environment-Specific Recommendations

### Development
```hcl
account_replication_type = "LRS"  # Locally redundant (cost-optimized)
access_tier              = "Hot"  # Immediate access
create_public_ips        = true   # Enable public access for testing
```

### Staging
```hcl
account_replication_type = "ZRS"  # Zone redundant (balanced)
access_tier              = "Hot"
network_rules            = true   # Basic restrictions
```

### Production
```hcl
account_replication_type = "GRS"  # Geo-redundant (HA)
access_tier              = "Hot"
enable_customer_managed_key = true    # Encryption with own keys
enable_diagnostics       = true       # Full monitoring
apply_network_rules      = true       # Strict firewall rules
```

## Troubleshooting

### "Storage account name must be globally unique"
- Storage accounts must have globally unique names
- Add environment/timestamp to name: `stg${app}${env}${random}`

### "Cannot create more than X storage accounts"
- Check Azure subscription quotas
- Request quota increase if needed

### "Access denied" when creating
- Verify RBAC permissions: Contributor or Storage Account Contributor role
- Check if resource group exists

## Version Compatibility

- Terraform: >= 1.0
- Azure Provider: >= 3.0
- Azure CLI: >= 2.40.0

## Related Modules

- Virtual Machines module
- Load Balancer module
- Networking foundations

## Maintenance

- Monitor costs for storage tiers and replication
- Review access logs monthly
- Rotate encryption keys annually (if CMK enabled)
- Archive old data to Archive tier for cost optimization
