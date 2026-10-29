variable "address_range" {
  type = set(string)
}

variable "bgp_community" {
  type = string
  default = ""
}

variable "ddos_protection_plan" {
  type = object({
    
  })
  default = { }
}

variable "dns_servers" {
  type = list(string)
  default = [ 
    "10.115.10.5", 
    "10.115.10.6" 
  ]
}

variable "edge_zone" {
  type = string
  default = ""
}

variable "encryption" {
  type = object({
    enforcement = optional(string)
  })
  default = { }
}

variable "flow_timeout_in_minutes" {
  type = number
  default = null
}

variable "environment" {
  type = string
}

variable "identity_type" {
  type = string
  default = "SystemAssigned"
}

variable "location" {
  type = string
  default = "eastus"
}

variable "resource_group_name" {
  type = string
}

variable "route_table_routes" {
  type = list(object({
    name = string
    address_prefix = string
    next_hop_type = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string, "10.115.2.134")
  }))
  default = [
    {
      name = "CS-Internet"
      address_prefix = "0.0.0.0/0"
    },
    {
      name = "CS-Default"
      address_prefix = "10.0.0.0/8"
    }
  ]
}

variable "security_group_id" {
  type = string
  default = ""
}

variable "service_endpoints" {
  type = set(string)
  default = []
  nullable = true
}

variable "solution_name" {
  type = string
}

variable "subnets" {
  type = list(object({
    name = string
    address_prefixes = list(string)
    security_group = optional(string)
    delegation = optional(list(object({
      name = string
      service_delegation = list(object({
        name = string
        actions = list(string)
      }))
    })))
    private_endpoint_network_policies = optional(string)
    private_link_services_network_policies_enabled = optional(bool)
    route_table_id = optional(string)
    service_endpoints = optional(set(string))
  }))
}
