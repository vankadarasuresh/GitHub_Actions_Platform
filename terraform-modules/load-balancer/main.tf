terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

# Create Public IP for Load Balancer
resource "azurerm_public_ip" "lb_ip" {
  name                = "pip-${var.loadbalancer_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.loadbalancer_sku
  domain_name_label   = lower(replace(var.loadbalancer_name, "_", "-"))
  idle_timeout_in_minutes = var.public_ip_idle_timeout

  tags = merge(
    var.tags,
    {
      "Type" = "PublicIP"
    }
  )
}

# Create Load Balancer
resource "azurerm_lb" "main" {
  name                = var.loadbalancer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.loadbalancer_sku
  sku_tier            = var.loadbalancer_sku_tier

  frontend_ip_configuration {
    name                 = var.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }

  tags = merge(
    var.tags,
    {
      "Type" = "LoadBalancer"
    }
  )

  depends_on = [azurerm_public_ip.lb_ip]
}

# Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = var.backend_pool_name
}

# Create Health Probe
resource "azurerm_lb_probe" "main" {
  name                = var.health_probe_name
  loadbalancer_id     = azurerm_lb.main.id
  protocol            = var.health_probe_protocol
  port                = var.health_probe_port
  request_path        = var.health_probe_path
  interval_in_seconds = var.health_probe_interval
  number_of_probes    = var.health_probe_unhealthy_threshold
}

# Create Load Balancing Rule for HTTP
resource "azurerm_lb_rule" "http" {
  count                          = var.enable_http_rule ? 1 : 0
  name                           = var.load_balancing_rule_name_http
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = var.lb_protocol
  frontend_port                  = var.lb_frontend_port_http
  backend_port                   = var.lb_backend_port_http
  frontend_ip_configuration_name = var.frontend_ip_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
  idle_timeout_in_minutes        = var.idle_timeout
  load_distribution              = var.load_distribution

  depends_on = [azurerm_lb_backend_address_pool.main, azurerm_lb_probe.main]
}

# Create Load Balancing Rule for HTTPS
resource "azurerm_lb_rule" "https" {
  count                          = var.enable_https_rule ? 1 : 0
  name                           = var.load_balancing_rule_name_https
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = var.lb_protocol
  frontend_port                  = var.lb_frontend_port_https
  backend_port                   = var.lb_backend_port_https
  frontend_ip_configuration_name = var.frontend_ip_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
  idle_timeout_in_minutes        = var.idle_timeout
  load_distribution              = var.load_distribution

  depends_on = [azurerm_lb_backend_address_pool.main, azurerm_lb_probe.main]
}

# Associate Network Interfaces with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = length(jsondecode(var.backend_pool_ids))
  network_interface_id    = jsondecode(var.backend_pool_ids)[count.index]
  ip_configuration_name   = "testConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# Optional: Inbound NAT Rules (for direct VM access)
resource "azurerm_lb_nat_rule" "main" {
  count                          = var.enable_nat_rules ? length(jsondecode(var.backend_pool_ids)) : 0
  name                           = "nat-rule-ssh-${count.index + 1}"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port                  = 2200 + count.index
  backend_port                   = 22
  frontend_ip_configuration_name = var.frontend_ip_name
}

# Associate NAT Rules with NICs
resource "azurerm_network_interface_nat_rule_association" "main" {
  count                 = var.enable_nat_rules ? length(jsondecode(var.backend_pool_ids)) : 0
  network_interface_id  = jsondecode(var.backend_pool_ids)[count.index]
  ip_configuration_name = "testConfiguration"
  nat_rule_id           = azurerm_lb_nat_rule.main[count.index].id
}

# Diagnostic Settings (optional)
resource "azurerm_monitor_diagnostic_setting" "lb_diagnostics" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "diag-${azurerm_lb.main.name}"
  target_resource_id         = azurerm_lb.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [azurerm_lb.main]
}
