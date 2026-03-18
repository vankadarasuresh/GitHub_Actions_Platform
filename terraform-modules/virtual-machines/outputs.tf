output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.main.name
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "network_security_group_name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.main.name
}

output "vm_ids" {
  description = "List of virtual machine IDs"
  value       = jsonencode([for vm in azurerm_linux_virtual_machine.main : vm.id])
}

output "vm_names" {
  description = "List of virtual machine names"
  value       = jsonencode([for vm in azurerm_linux_virtual_machine.main : vm.name])
}

output "vm_computer_names" {
  description = "List of virtual machine computer names"
  value       = jsonencode([for vm in azurerm_linux_virtual_machine.main : vm.computer_name])
}

output "network_interface_ids" {
  description = "List of network interface IDs (for load balancer backend pool)"
  value       = jsonencode([for nic in azurerm_network_interface.main : nic.id])
}

output "network_interface_names" {
  description = "List of network interface names"
  value       = jsonencode([for nic in azurerm_network_interface.main : nic.name])
}

output "vm_private_ips" {
  description = "List of private IP addresses"
  value       = jsonencode([for nic in azurerm_network_interface.main : nic.private_ip_address])
}

output "vm_private_ips_map" {
  description = "Map of VM names to private IPs"
  value = {
    for i, vm in azurerm_linux_virtual_machine.main : vm.name => azurerm_network_interface.main[i].private_ip_address
  }
}

output "vm_public_ips" {
  description = "List of public IP addresses"
  value       = jsonencode([for ip in azurerm_public_ip.main : ip.ip_address])
}

output "vm_public_ips_map" {
  description = "Map of VM names to public IPs"
  value = {
    for i, ip in azurerm_public_ip.main : azurerm_linux_virtual_machine.main[i].name => ip.ip_address
  }
}

output "vm_public_ip_ids" {
  description = "List of public IP resource IDs"
  value       = jsonencode([for ip in azurerm_public_ip.main : ip.id])
}

output "vm_public_fqdns" {
  description = "List of public FQDNs (if configured)"
  value       = jsonencode([for ip in azurerm_public_ip.main : ip.fqdn])
}

output "vm_identity_principal_ids" {
  description = "List of system-assigned managed identity principal IDs"
  value       = jsonencode([for vm in azurerm_linux_virtual_machine.main : vm.identity[0].principal_id])
}

output "vm_admin_username" {
  description = "Admin username for VMs"
  value       = var.admin_username
}

output "vm_size" {
  description = "VM size (SKU)"
  value       = var.vm_size
}

output "vm_count" {
  description = "Number of VMs created"
  value       = var.vm_count
}

output "connection_info" {
  description = "SSH connection information for VMs"
  value = {
    admin_user = var.admin_username
    private_ips = jsonencode([for nic in azurerm_network_interface.main : nic.private_ip_address])
    public_ips = var.create_public_ips ? jsonencode([for ip in azurerm_public_ip.main : ip.ip_address]) : "N/A"
  }
}
