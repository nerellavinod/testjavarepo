resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
}

resource "azurerm_virtual_network" "vnet" {
  name                = "hmnao-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "web" {
  name                 = "web-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_web]
}

resource "azurerm_subnet" "pe" {
  name                 = "private-endpoints-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_pe]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}
