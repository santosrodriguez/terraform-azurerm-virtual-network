terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
    random = {
      source = "hashicorp/random"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [ azurerm.CS-PNP-CommonServicesInfra ]
    }
  }
}

resource "random_string" "suffix" {
  length = 4
  upper = false
  special = false
  numeric = true
  lower = false
}

resource "azurecaf_name" "vnet_name" {
  resource_type = "azurerm_virtual_network"
  suffixes = [ var.solution_name, var.location, var.environment, random_string.suffix.result ]
}

resource "azurerm_route_table" "rt" {
  name = "rt-${azurecaf_name.vnet_name.result}"
  location = var.location
  resource_group_name = "Infrastructure_RG"
  dynamic "route" {
    for_each = { for k, v in var.route_table_routes : k => v }
    content {
      address_prefix = route.value.address_prefix
      name = route.value.name
      next_hop_type = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name = azurecaf_name.vnet_name.result
  address_space = var.address_range
  location = var.location
  resource_group_name = "Infrastructure_RG"
  dns_servers = var.dns_servers
  dynamic "subnet" {
    for_each = { for k, v in var.subnets : k => v }
    content {
      name = subnet.value.name
      address_prefixes = subnet.value.address_prefixes
      service_endpoints = subnet.value.service_endpoints
      route_table_id = azurerm_route_table.rt.id
      dynamic "delegation" {
       for_each = subnet.value.delegation != null ? { for k, v in subnet.value.delegation : k => v } : {}
        content {
          name = delegation.value.name
          service_delegation = delegation.value.service_delegation
        }
      }
    }
  }
  depends_on = [ azurerm_route_table.rt ]
}

resource "azurerm_virtual_network_peering" "hub_peering" {
  name = "peer-${azurecaf_name.vnet_name.result}"
  provider = azurerm.CS-PNP-CommonServicesInfra
  resource_group_name = "FIREWALL_RG"
  virtual_network_name = "prd-eastus-paloew-vnet1"
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  use_remote_gateways = false
  depends_on = [ 
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_virtual_network_peering" "spoke_peering" {
  name = "prd-eastus-paloew-vnet1"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = "/subscriptions/56bdaed4-70cf-4a28-8fb8-0efc135bb29f/resourceGroups/FIREWALL_RG/providers/Microsoft.Network/virtualNetworks/prd-eastus-paloew-vnet1"
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  use_remote_gateways = false
  depends_on = [ 
    azurerm_virtual_network.vnet
  ]
}
