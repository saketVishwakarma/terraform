output "resource_group_name" {
  value       = azurerm_resource_group.test_net.name
  description = "The name of the resource group"
}

output "admin_username" {
  value       = var.admin_username
  description = "The admin username for the VM"
}

output "vm_id" {
  value       = azurerm_virtual_machine.vmtest.id
  description = "The resource ID of the virtual machine"
}

output "nic_id" {
  value       = azurerm_network_interface.main.id
  description = "The ID of the network interface"
}

output "vm_private_ip" {
  value       = azurerm_network_interface.main.private_ip_address
  description = "The private IP address of the virtual machine"
}
