# Virtual Network Terraform Module

A reusable Terraform module to provision an **Azure Virtual Network** (VNet) with configurable subnets, DNS, route tables, service endpoints, and security integration.  

> **Scope:** This module focuses on VNet and subnet configuration, including route table entries and NSG association via `security_group_id`. It assumes the resource group is pre-created.

## Requirements

- Terraform >= 1.5
- AzureRM provider >= 3.x
- An existing **Resource Group** referenced by `resource_group_name`.

---
## Usage

```hcl
module "vnet" {
  source = "caresource.pe.jfrog.io/shared-tfmodules-internal__network/virtual-network/azurerm" # update to actual path
  version = "#.#.#"
  providers = 
  {
    azurerm = azurerm
    azurerm.CS-PNP-CommonServicesInfra = azurerm.CS-PNP-CommonServicesInfra
  } 
  solution_name       = "cpd"
  environment         = "prod"
  instance_number     = 1
  resource_group_name = "rg-cpd-prod-eastus"
  location            = "eastus"

  address_range = [ "VNet_cidr_range/## ]
  
  # Optional
  subnets = [
    {
      # Subnet without delegation
      name                                 = "snet-1"
      address_prefixes                     = ["###.###.###.###/##"]
      service_endpoints                    = []
    },
    {
      # Subnet With Delegation
      name             = "snet-2"
      address_prefixes = ["###.###.###.###/##"]
      delegation = [
        {
          name = "db-delegation"
          service_delegation = {
            name    = "Microsoft.<resource>/<type>"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
  ]
}
```

---

## Inputs

| Name | Type | Required | Default | Description |
|---|---|:---:|---|---|
| `address_range` | `set(string)` | ✅ | — | VNet address spaces (CIDRs), e.g., `{\"10.115.0.0/16\"}`. |
| `dns_servers` | `list(string)` | ❌ | `["10.115.10.5","10.115.10.6"]` | Custom DNS servers for the VNet. Empty/omit to use Azure-provided DNS. |
| `edge_zone` | `string` | ❌ | n/a | Optional Edge Zone name for VNet placement. |
| `encryption` | `object({})` | ❌ | `{}` | Optional encryption configuration. `enforcement` typically `"AllowUnencrypted"` or `"DropUnencrypted"`. |
| `flow_timeout_in_minutes` | `number` | ❌ | n-a | VNet flow timeout (minutes). `null` to use Azure default. |
| `environment` | `string` | ✅ | n/a | Environment code, e.g., `dev`, `test`, `prod`. Used in naming/labels. |
| `identity_type` | `string` | ❌ | `"SystemAssigned"` | VNet identity type (if applicable for resources in scope). |
| `instance_number` | `number` | ✅ | n/a | Instance ordinal for multi-deploy scenarios (e.g., `1`, `2`). |
| `location` | `string` | ❌ | `"eastus"` | Azure region for the VNet. |
| `resource_group_name` | `string` | ✅ | — | Name of the existing resource group to place the VNet. |
| `route_table_routes` | `list(object({}))` | ❌ | See defaults below | Route entries to attach (commonly to a VNet-level route table or per-subnet). |
| `service_endpoints` | `set(string)` | ❌ | `[]` (nullable) | VNet-level service endpoints (subnets may specify their own). |
| `solution_name` | `string` | ✅ | n/a | Solution/app short name used in resource naming. |
| `subnets` | `list(object())` | ✅ | n/a |
---

## Outputs

| Output | Description |
|--------|-------------|
| azurerm_virtual_network.vnet | Virtual Network Object

---
