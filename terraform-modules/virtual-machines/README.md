# Azure Virtual Machines Terraform Module

Production-ready Terraform module for deploying Azure Virtual Machines with networking, security, and identity management.

## Features

✅ **Networking**
- Virtual network and subnet creation
- Network Security Groups with default rules
- Network interfaces with flexible IP allocation
- Optional public IP addresses
- Service endpoints support

✅ **Security**
- SSH key-only authentication (no passwords)
- Network Security Group rules (SSH, HTTP, HTTPS)
- Optional system-assigned managed identity
- Optional user-assigned managed identity
- Disk encryption support

✅ **Flexibility**
- Multiple VM support (vm_count parameter)
- Configurable VM sizes and images
- Custom data script support
- Extensions for monitoring and configuration
- Multiple Linux distributions supported

✅ **Monitoring & Operations**
- Azure Monitor agent extension
- Optional disk encryption with CMK
- System-managed identities for RBAC
- Graceful shutdown configuration

## Usage

### Basic Example

```hcl
module "virtual_machines" {
  source = "./terraform-modules/virtual-machines"

  environment                    = "prod"
  location                       = "eastus"
  resource_group_name            = "rg-myapp-prod"
  
  virtual_network_name           = "vnet-myapp-prod"
  subnet_name                    = "subnet-vms-prod"
  network_interface_name_prefix  = "nic-myapp-prod"
  
  vm_name_prefix                 = "vm-myapp-prod"
  vm_count                       = 4
  vm_size                        = "Standard_D2s_v3"
  
  admin_username                 = "azureuser"
  admin_ssh_public_key           = file("~/.ssh/id_rsa.pub")
  
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### With Custom Network Configuration

```hcl
module "virtual_machines" {
  source = "./terraform-modules/virtual-machines"

  environment              = "prod"
  resource_group_name      = "rg-myapp-prod"
  
  # Custom network settings
  virtual_network_name     = "vnet-myapp-prod"
  address_space            = ["10.0.0.0/16"]
  subnet_name              = "subnet-vms-prod"
  subnet_address_prefixes  = ["10.0.1.0/24"]
  service_endpoints        = ["Microsoft.Storage"]
  
  # VM configuration
  vm_count                 = 2
  vm_size                  = "Standard_B2s"
  image_publisher          = "Canonical"
  image_offer              = "0001-com-ubuntu-server-focal"
  image_sku                = "20_04-lts-gen2"
  image_version            = "latest"
  
  admin_ssh_public_key     = file("~/.ssh/id_rsa.pub")
  
  # Allow SSH only from specific IP
  ssh_source_address_prefix = "203.0.113.0/32"
  
  tags = var.tags
}
```

### With Monitoring and Custom Data

```hcl
module "virtual_machines" {
  source = "./terraform-modules/virtual-machines"

  environment              = "prod"
  resource_group_name      = "rg-myapp-prod"
  
  vm_count                 = 4
  vm_size                  = "Standard_D2s_v3"
  admin_ssh_public_key     = file("~/.ssh/id_rsa.pub")
  
  # Bootstrap script
  custom_data              = file("${path.module}/bootstrap.sh")
  
  # Enable monitoring
  enable_azure_monitor_agent = true
  
  # Accelerated networking for high-performance
  enable_accelerated_networking = true
  
  # Managed identity for RBAC
  enable_system_managed_identity = true
  
  tags = var.tags
}
```

### With Disk Encryption

```hcl
module "virtual_machines" {
  source = "./terraform-modules/virtual-machines"

  environment              = "prod"
  resource_group_name      = "rg-myapp-prod"
  
  vm_count                 = 4
  admin_ssh_public_key     = file("~/.ssh/id_rsa.pub")
  
  # Enable disk encryption
  enable_disk_encryption   = true
  key_vault_key_id         = azurerm_key_vault_key.main.id
  
  tags = var.tags
}
```

## Variables

### Required
- `environment` - Environment name (dev, staging, prod)
- `resource_group_name` - Name of resource group
- `virtual_network_name` - Name of virtual network
- `subnet_name` - Name of subnet
- `network_interface_name_prefix` - Prefix for NIC names
- `vm_name_prefix` - Prefix for VM names
- `admin_ssh_public_key` - Public SSH key content

### Optional
- `location` - Azure region (default: eastus)
- `vm_count` - Number of VMs (default: 2)
- `vm_size` - VM size SKU (default: Standard_B2s)
- `admin_username` - Admin user (default: azureuser)
- `create_public_ips` - Create public IPs (default: true)
- `enable_accelerated_networking` - High-performance network (default: false)

See `variables.tf` for complete list.

## Outputs

```hcl
# VM Information
vm_ids                              # List of VM IDs
vm_names                            # List of VM names
vm_computer_names                   # List of computer names

# Networking
network_interface_ids               # List of NIC IDs (for LB backend pool)
network_interface_names             # List of NIC names
vm_private_ips                      # List of private IP addresses
vm_public_ips                       # List of public IP addresses (if created)
vm_public_fqdns                     # List of public FQDNs

# Identity
vm_identity_principal_ids           # System-assigned MSI principal IDs

# Connection Info
connection_info                     # SSH connection details
vm_admin_username                   # Admin username
```

## Network Security Group Rules

Default inbound rules created:
- **SSH (Port 22)** - From `ssh_source_address_prefix` (restrict in prod!)
- **HTTP (Port 80)** - From any
- **HTTPS (Port 443)** - From any

Customize by modifying the security_rule blocks in `main.tf`.

## Best Practices Implemented

1. **Security**
   - SSH key-only authentication (passwords disabled)
   - SSH restricted by source IP
   - HTTP/HTTPS ports open for web apps
   - Network Security Groups for traffic control

2. **Operations**
   - Managed identities for RBAC
   - Azure Monitor agent for monitoring
   - Custom data support for initialization
   - Graceful shutdown configuration

3. **Networking**
   - Configurable virtual networks
   - Flexible IP allocation
   - Optional public IPs
   - Service endpoints support

4. **High Availability**
   - Multiple VM support
   - Network interface NICs compatible with load balancers
   - Distributed across availability zones (if configured)

## Environment-Specific Recommendations

### Development
```hcl
vm_count                   = 1              # Cost optimization
vm_size                    = "Standard_B2s" # Small size
create_public_ips          = true           # For testing
ssh_source_address_prefix  = "0.0.0.0/0"    # Open for testing
```

### Staging
```hcl
vm_count                   = 2              # Basic redundancy
vm_size                    = "Standard_B2s"
create_public_ips          = false          # Only for LB
ssh_source_address_prefix  = "203.0.113.0/24" # Restricted
```

### Production
```hcl
vm_count                   = 4              # High availability
vm_size                    = "Standard_D2s_v3" # Production size
create_public_ips          = false          # Use load balancer only
ssh_source_address_prefix  = "203.0.113.50/32" # Restricted to bastion
enable_accelerated_networking = true
enable_azure_monitor_agent = true
```

## Custom Data (Bootstrap Script)

Provide initialization script:

```hcl
custom_data = file("${path.module}/bootstrap.sh")
```

Example bootstrap.sh:
```bash
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
```

## SSH Connection Examples

After deployment:

```bash
# SSH to first VM (if public IP created)
ssh -i ~/.ssh/id_rsa azureuser@<public_ip>

# SSH through load balancer NAT rule (if configured)
ssh -i ~/.ssh/id_rsa azureuser@<lb_fqdn> -p 2200

# SSH via private IP (from within VNet or bastion)
ssh -i ~/.ssh/id_rsa azureuser@10.0.1.4
```

## Troubleshooting

### "SSH key format not supported"
- Use RSA or ECDSA keys (not ED25519)
- Ensure key is in OpenSSH format: `ssh-keygen -m pem -t rsa`

### "Quota exceeded for VM creation"
- Check Azure subscription quotas
- Request quota increase for virtual machines and cores

### "Cannot create VM - network resource not available"
- Ensure virtual network and subnet exist
- Verify resource group permissions

## Version Compatibility

- Terraform: >= 1.0
- Azure Provider: >= 3.0
- Azure CLI: >= 2.40.0

## Related Modules

- Load Balancer module (attach VMs to backend pool)
- Storage Account module (for data storage)
- Network infrastructure

## Maintenance

- Regularly update OS patches
- Monitor disk space and memory
- Review security group rules quarterly
- Update custom data scripts as needed
- Rotate SSH keys annually
