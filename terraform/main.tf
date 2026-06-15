terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "7b865dfe-b697-49e6-b0d6-5e2a41a056a9"
}

resource "azurerm_resource_group" "landingzone" {
  name     = "rg-landingzone"
  location = "eastus"
}

# VNet Hub
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.landingzone.location
  resource_group_name = azurerm_resource_group.landingzone.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "hub_default" {
  name                 = "snet-hub-default"
  resource_group_name  = azurerm_resource_group.landingzone.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/26"]
}

# VNet Spoke 1
resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1"
  location            = azurerm_resource_group.landingzone.location
  resource_group_name = azurerm_resource_group.landingzone.name
  address_space       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "spoke1_default" {
  name                 = "snet-spoke1-default"
  resource_group_name  = azurerm_resource_group.landingzone.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.0.1.0/26"]
}

# VNet Spoke 2
resource "azurerm_virtual_network" "spoke2" {
  name                = "vnet-spoke2"
  location            = azurerm_resource_group.landingzone.location
  resource_group_name = azurerm_resource_group.landingzone.name
  address_space       = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "spoke2_default" {
  name                 = "snet-spoke2-default"
  resource_group_name  = azurerm_resource_group.landingzone.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.0.2.0/26"]
}

# Peering: Hub -> Spoke 1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                         = "peer-hub-to-spoke1"
  resource_group_name          = azurerm_resource_group.landingzone.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Peering: Spoke 1 -> Hub
resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                         = "peer-spoke1-to-hub"
  resource_group_name          = azurerm_resource_group.landingzone.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Peering: Hub -> Spoke 2
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                         = "peer-hub-to-spoke2"
  resource_group_name          = azurerm_resource_group.landingzone.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Peering: Spoke 2 -> Hub
resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                         = "peer-spoke2-to-hub"
  resource_group_name          = azurerm_resource_group.landingzone.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
