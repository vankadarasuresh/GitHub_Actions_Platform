# Azure Load Balancer Terraform Module

Production-ready Terraform module for deploying Azure Load Balancers with health probes, NAT rules, and comprehensive monitoring.

## Features

✅ **Load Balancing**
- HTTP and HTTPS rule support
- Multiple load distribution modes
- Health probe configuration
- TCP reset on idle
- Floating IP support

✅ **Networking**
- Public IP management
- Frontend and backend pool configuration
- Inbound NAT rules (optional)
- Network of backends management

✅ **High Availability**
- Standard SKU (recommended for prod)
- Multiple backend endpoints
- Health check intervals and thresholds
- Idle timeout configuration

✅ **Monitoring & Security**
- Diagnostic settings integration
- Azure Monitor metrics
- Connection tracking
- Access logging support

## Usage

### Basic HTTP Load Balancer

```hcl
module "load_balancer" {
  source = "./terraform-modules/load-balancer"

  environment                = "prod"
  location                   = "eastus"
  resource_group_name        = "rg-myapp-prod"
  
  loadbalancer_name          = "lb-myapp-prod"
  loadbalancer_sku           = "Standard"
  
  frontend_ip_name           = "frontend-ip-prod"
  backend_pool_name          = "backend-pool-prod"
  health_probe_name          = "health-probe-prod"
  load_balancing_rule_name_http = "lb-rule-http"
  
  # Backend VMs (from VM module outputs)
  backend_pool_ids = module.virtual_machines.network_interface_ids
  
  # HTTP only
  enable_http_rule  = true
  enable_https_rule = false
  
  # Health probe configuration
  health_probe_protocol     = "Http"
  health_probe_port         = 80
  health_probe_path         = "/"
  health_probe_interval     = 15
  
  tags = {
    Environment = "production"
  }
}
```

### HTTP + HTTPS Load Balancer

```hcl
module "load_balancer" {
  source = "./terraform-modules/load-balancer"

  environment         = "prod"
  resource_group_name = "rg-myapp-prod"
  
  loadbalancer_name   = "lb-myapp-prod"
  
  # Enable both HTTP and HTTPS
  enable_http_rule              = true
  load_balancing_rule_name_http = "lb-rule-http"
  lb_frontend_port_http         = 80
  lb_backend_port_http          = 80
  
  enable_https_rule               = true
  load_balancing_rule_name_https  = "lb-rule-https"
  lb_frontend_port_https          = 443
  lb_backend_port_https           = 8443  # Custom backend HTTPS port
  
  # Health probe hits HTTP endpoint
  health_probe_protocol = "Http"
  health_probe_port     = 80
  health_probe_path     = "/health"
  
  # Backend endpoints
  backend_pool_ids = module.virtual_machines.network_interface_ids
  
  tags = var.tags
}
```

### Advanced Configuration

```hcl
module "load_balancer" {
  source = "./terraform-modules/load-balancer"

  environment         = "prod"
  resource_group_name = "rg-myapp-prod"
  
  loadbalancer_name   = "lb-myapp-prod"
  loadbalancer_sku    = "Standard"
  
  # Health probe - strict for production
  health_probe_protocol           = "Http"
  health_probe_port               = 80
  health_probe_path               = "/api/health"
  health_probe_interval           = 15          # Check every 15 seconds
  health_probe_unhealthy_threshold = 3           # Mark unhealthy after 3 failures
  
  # Load balancing rules
  enable_http_rule              = true
  lb_protocol                   = "Tcp"
  lb_frontend_port_http         = 80
  lb_backend_port_http          = 8080       # Custom app port
  enable_tcp_reset              = true       # Reset on idle
  idle_timeout                  = 30         # 30 minute timeout
  load_distribution             = "SourceIP" # Session persistence
  
  # Direct VM access via NAT rules
  enable_nat_rules = true  # SSH to backend VMs via ports 2200-2203
  
  # Backend endpoints
  backend_pool_ids = module.virtual_machines.network_interface_ids
  
  # Diagnostics
  enable_diagnostics             = true
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  diagnostics_retention_days     = 90
  
  tags = var.tags
}
```

## Variables

### Required
- `environment` - Environment name (dev, staging, prod)
- `resource_group_name` - Name of resource group
- `loadbalancer_name` - Name of load balancer
- `frontend_ip_name` - Frontend IP config name
- `backend_pool_name` - Backend pool name
- `health_probe_name` - Health probe name
- `backend_pool_ids` - JSON array of NIC IDs from VMs

### Optional
- `location` - Azure region (default: eastus)
- `loadbalancer_sku` - Basic or Standard (default: Standard)
- `enable_http_rule` - Create HTTP rule (default: true)
- `enable_https_rule` - Create HTTPS rule (default: false)
- `health_probe_path` - Health check path (default: /)
- `health_probe_interval` - Probe interval seconds (default: 15)
- `enable_nat_rules` - Create NAT rules (default: false)

See `variables.tf` for complete list.

## Outputs

```hcl
# Load Balancer
loadbalancer_id                          # Load balancer resource ID
loadbalancer_name                        # Load balancer name

# Public IP
loadbalancer_public_ip_address           # Public IP address
loadbalancer_fqdn                        # Fully qualified domain name
loadbalancer_public_ip_name              # Public IP resource name

# Frontend/Backend
loadbalancer_frontend_ip_configuration_id # Frontend config ID
loadbalancer_backend_address_pool_id     # Backend pool ID
backend_pool_count                       # Number of backends

# Health & Rules
health_probe_id                          # Health probe ID
http_rule_id                             # HTTP rule ID (if created)
https_rule_id                            # HTTPS rule ID (if created)

# Connection Info
loadbalancer_connection_info             # IP, FQDN, ports

# NAT Rules (if enabled)
nat_rule_ids                             # IDs of NAT rules
nat_rules_mapping                        # Frontend/backend port mapping
```

## Backend Pool Integration

The module integrates with the VM module via `network_interface_ids`:

```hcl
# From VM module output
backend_pool_ids = module.virtual_machines.network_interface_ids

# Example: jsonencode(["/subscriptions/.../nic-1", "/subscriptions/.../nic-2"])
```

The module automatically associates these NICs with the backend pool.

## Health Probe Configuration

### HTTP Health Probe
```hcl
health_probe_protocol = "Http"
health_probe_port     = 80
health_probe_path     = "/health"        # Application health endpoint
```

### TCP Health Probe
```hcl
health_probe_protocol = "Tcp"
health_probe_port     = 80               # Just check if port is listening
health_probe_path     = ""               # Not used for TCP
```

## Best Practices Implemented

1. **High Availability**
   - Standard SKU recommended (always use in prod)
   - Health probes every 15 seconds
   - Multiple backend endpoints
   - Configurable timeout settings

2. **Security**
   - Standard SKU with best security
   - Public IP separation from LB
   - Network Security Groups integration
   - Optional NAT rules for SSH

3. **Performance**
   - Configurable load distribution (Default, SourceIP, SourceIPProtocol)
   - TCP reset on idle
   - Adjustable timeout
   - Floating IP support for special cases

4. **Operations**
   - Diagnostic settings support
   - Azure Monitor integration
   - Health probe status tracking
   - Connection logging

## Environment-Specific Recommendations

### Development
```hcl
loadbalancer_sku              = "Basic"  # Cost optimization
enable_http_rule              = true
enable_https_rule             = false
health_probe_interval         = 30       # Less frequent
enable_diagnostics            = false
enable_nat_rules              = true     # For SSH debugging
```

### Staging
```hcl
loadbalancer_sku              = "Standard"
enable_http_rule              = true
enable_https_rule             = false
health_probe_interval         = 15
health_probe_path             = "/"
enable_diagnostics            = true
```

### Production
```hcl
loadbalancer_sku              = "Standard"
enable_http_rule              = true
enable_https_rule             = true     # HTTPS only recommended
health_probe_protocol         = "Http"
health_probe_path             = "/api/health"  # Specific endpoint
health_probe_interval         = 15
health_probe_unhealthy_threshold = 3
enable_tcp_reset              = true
enable_diagnostics            = true
diagnostics_retention_days    = 90
idle_timeout                  = 30
```

## Access Methods

### Via Load Balancer Public IP
```bash
curl http://lb-myapp-prod.eastus.cloudapp.azure.com
```

### Via Load Balancer FQDN
```bash
curl http://40.1.1.50  # Public IP address
```

### Direct to Backend VM (if NAT rules enabled)
```bash
ssh -i ~/.ssh/id_rsa azureuser@lb-myapp-prod.eastus.cloudapp.azure.com -p 2200
# Port 2200 → First backend VM SSH
# Port 2201 → Second backend VM SSH, etc.
```

## Troubleshooting

### "All backends unhealthy"
- Verify application is running on backend VMs
- Check health probe path is correct
- Ensure security group allows probe traffic
- Check backend port matches app port

### "Cannot associate NIC with backend pool"
- Verify NIC format is correct JSON array
- Check NICs are in same VNet as LB
- Ensure NICs are not already associated

### "Public IP FQDN not resolving"
- Wait 1-2 minutes after creation
- Verify domain_name_label is unique
- Check DNS propagation with `nslookup`

## Version Compatibility

- Terraform: >= 1.0
- Azure Provider: >= 3.0
- Azure CLI: >= 2.40.0

## Related Modules

- Virtual Machines module (provides NICs for backend)
- Storage Account module (for application data)
- Network infrastructure

## Maintenance

- Monitor backend health status weekly
- Review traffic patterns monthly
- Update health probe paths when app changes
- Audit NAT rules for security
- Archive diagnostics logs quarterly
