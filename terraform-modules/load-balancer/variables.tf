variable "resource_group_name" {
  description = "Name of the resource group (created by resource-group module)"
  type        = string
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1-90 characters."
  }
}

variable "location" {
  description = "Azure region for resources (from resource-group module)"
  type        = string
}

variable "loadbalancer_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "loadbalancer_sku" {
  description = "SKU of the load balancer (Basic or Standard)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.loadbalancer_sku)
    error_message = "Load balancer SKU must be Basic or Standard."
  }
}

variable "loadbalancer_sku_tier" {
  description = "SKU tier of the load balancer (Regional, Global)"
  type        = string
  default     = "Regional"
  validation {
    condition     = contains(["Regional", "Global"], var.loadbalancer_sku_tier)
    error_message = "Load balancer SKU tier must be Regional or Global."
  }
}

variable "frontend_ip_name" {
  description = "Name of frontend IP configuration"
  type        = string
}

variable "backend_pool_name" {
  description = "Name of backend address pool"
  type        = string
}

variable "backend_pool_ids" {
  description = "JSON array of network interface IDs to add to backend pool"
  type        = string
}

variable "health_probe_name" {
  description = "Name of health probe"
  type        = string
}

variable "health_probe_protocol" {
  description = "Health probe protocol (Http, Https, Tcp)"
  type        = string
  default     = "Http"
  validation {
    condition     = contains(["Http", "Https", "Tcp"], var.health_probe_protocol)
    error_message = "Health probe protocol must be Http, Https, or Tcp."
  }
}

variable "health_probe_port" {
  description = "Health probe port"
  type        = number
  default     = 80
  validation {
    condition     = var.health_probe_port >= 1 && var.health_probe_port <= 65535
    error_message = "Health probe port must be between 1-65535."
  }
}

variable "health_probe_path" {
  description = "Health probe path (for Http/Https)"
  type        = string
  default     = "/"
}

variable "health_probe_interval" {
  description = "Health probe interval in seconds"
  type        = number
  default     = 15
  validation {
    condition     = var.health_probe_interval >= 5 && var.health_probe_interval <= 300
    error_message = "Health probe interval must be between 5-300 seconds."
  }
}

variable "health_probe_unhealthy_threshold" {
  description = "Number of probe failures before unhealthy"
  type        = number
  default     = 2
  validation {
    condition     = var.health_probe_unhealthy_threshold >= 2 && var.health_probe_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2-10."
  }
}

variable "enable_http_rule" {
  description = "Create HTTP load balancing rule"
  type        = bool
  default     = true
}

variable "load_balancing_rule_name_http" {
  description = "Name of HTTP load balancing rule"
  type        = string
  default     = "lb-rule-http"
}

variable "lb_protocol" {
  description = "Load balancing protocol (Tcp, Udp)"
  type        = string
  default     = "Tcp"
  validation {
    condition     = contains(["Tcp", "Udp"], var.lb_protocol)
    error_message = "Load balancing protocol must be Tcp or Udp."
  }
}

variable "lb_frontend_port_http" {
  description = "Frontend port for HTTP"
  type        = number
  default     = 80
}

variable "lb_backend_port_http" {
  description = "Backend port for HTTP"
  type        = number
  default     = 80
}

variable "enable_https_rule" {
  description = "Create HTTPS load balancing rule"
  type        = bool
  default     = false
}

variable "load_balancing_rule_name_https" {
  description = "Name of HTTPS load balancing rule"
  type        = string
  default     = "lb-rule-https"
}

variable "lb_frontend_port_https" {
  description = "Frontend port for HTTPS"
  type        = number
  default     = 443
}

variable "lb_backend_port_https" {
  description = "Backend port for HTTPS"
  type        = number
  default     = 443
}

variable "idle_timeout" {
  description = "Idle timeout in minutes"
  type        = number
  default     = 4
  validation {
    condition     = var.idle_timeout >= 4 && var.idle_timeout <= 100
    error_message = "Idle timeout must be between 4-100 minutes."
  }
}

variable "load_distribution" {
  description = "Load distribution mode (Default, SourceIP, SourceIPProtocol)"
  type        = string
  default     = "Default"
  validation {
    condition     = contains(["Default", "SourceIP", "SourceIPProtocol"], var.load_distribution)
    error_message = "Load distribution must be Default, SourceIP, or SourceIPProtocol."
  }
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "public_ip_idle_timeout" {
  description = "Public IP idle timeout in minutes"
  type        = number
  default     = 4
}

variable "enable_nat_rules" {
  description = "Create NAT rules for direct backend access"
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "diagnostics_retention_days" {
  description = "Number of days to retain diagnostics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
