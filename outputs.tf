output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  value = { for subnet in azurerm_virtual_network.vnet.subnet : subnet.name => subnet.id }
}

output "route_table_id" {
  value = azurerm_route_table.rt.id
}

output "route_table_name" {
  value = azurerm_route_table.rt.name
}

output "hub_peering_id" {
  value = azurerm_virtual_network_peering.hub_peering.id
}

output "spoke_peering_id" {
  value = azurerm_virtual_network_peering.spoke_peering.id
}
