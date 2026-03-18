
output "loadbalancer_id" {
  description = "The ID of the Load Balancer"
  value       = azurerm_lb.main.id
}

output "loadbalancer_name" {
  description = "The name of the Load Balancer"
  value       = azurerm_lb.main.name
}

output "loadbalancer_frontend_ip_configuration_id" {
  description = "The ID of the frontend IP configuration"
  value       = azurerm_lb.main.frontend_ip_configuration[0].id
}

output "loadbalancer_frontend_ip_configuration_name" {
  description = "The name of the frontend IP configuration"
  value       = azurerm_lb.main.frontend_ip_configuration[0].name
}

output "loadbalancer_frontend_ip_configuration_private_ip" {
  description = "The private IP address of frontend (if applicable)"
  value       = try(azurerm_lb.main.frontend_ip_configuration[0].private_ip_address, null)
}

output "loadbalancer_public_ip_id" {
  description = "The ID of the public IP address"
  value       = azurerm_public_ip.lb_ip.id
}

output "loadbalancer_public_ip_address" {
  description = "The public IP address of the Load Balancer"
  value       = azurerm_public_ip.lb_ip.ip_address
}

output "loadbalancer_fqdn" {
  description = "The FQDN of the Load Balancer"
  value       = azurerm_public_ip.lb_ip.fqdn
}

output "loadbalancer_public_ip_name" {
  description = "The name of the public IP address"
  value       = azurerm_public_ip.lb_ip.name
}

output "loadbalancer_backend_address_pool_id" {
  description = "The ID of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "loadbalancer_backend_address_pool_name" {
  description = "The name of the backend address pool"
  value       = azurerm_lb_backend_address_pool.main.name
}

output "loadbalancer_backend_pool_backend_ips" {
  description = "The backend IP addresses in the pool"
  value       = azurerm_lb_backend_address_pool.main.backend_ip_configurations
}

output "health_probe_id" {
  description = "The ID of the health probe"
  value       = azurerm_lb_probe.main.id
}

output "health_probe_name" {
  description = "The name of the health probe"
  value       = azurerm_lb_probe.main.name
}

output "http_rule_id" {
  description = "The ID of the HTTP load balancing rule"
  value       = try(azurerm_lb_rule.http[0].id, null)
}

output "http_rule_name" {
  description = "The name of the HTTP load balancing rule"
  value       = try(azurerm_lb_rule.http[0].name, null)
}

output "https_rule_id" {
  description = "The ID of the HTTPS load balancing rule"
  value       = try(azurerm_lb_rule.https[0].id, null)
}

output "https_rule_name" {
  description = "The name of the HTTPS load balancing rule"
  value       = try(azurerm_lb_rule.https[0].name, null)
}

output "nat_rule_ids" {
  description = "The IDs of NAT rules (if created)"
  value       = try(azurerm_lb_nat_rule.main[*].id, [])
}

output "nat_rules_mapping" {
  description = "Mapping of NAT rules to frontend ports"
  value = {
    for idx, rule in azurerm_lb_nat_rule.main : 
    "${idx + 1}" => {
      frontend_port = rule.frontend_port
      backend_port  = rule.backend_port
    }
  }
}

output "loadbalancer_sku" {
  description = "The SKU of the load balancer"
  value       = azurerm_lb.main.sku
}

output "loadbalancer_connection_info" {
  description = "Connection information for the load balancer"
  value = {
    public_ip  = azurerm_public_ip.lb_ip.ip_address
    fqdn       = azurerm_public_ip.lb_ip.fqdn
    http_port  = var.enable_http_rule ? var.lb_frontend_port_http : null
    https_port = var.enable_https_rule ? var.lb_frontend_port_https : null
  }
}

output "backend_pool_count" {
  description = "Number of backend endpoints in the pool"
  value       = length(jsondecode(var.backend_pool_ids))
}
