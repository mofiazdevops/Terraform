terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.21.1"
    }
  }
}

provider "azurerm" {
    features {
      
    }
  # Configuration options
    subscription_id = "25bcaf0e-1168-4666-81b9-0ff6600bf7e5"
    client_id = "a783b1a4-9f7a-469e-b68a-67bf8156fd6e"
    client_secret = ""
    tenant_id = "c496557c-4988-4f92-bec9-d4382b137c96"
}

resource "azurerm_resource_group" "RG" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network.name          
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]  
    depends_on = [ azurerm_resource_group.RG ]   # Ensures the resource group is created before this subnet

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "subnetA" {           # Now Create sperate subnet_block
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = local.subnets[0].address_prefix
  depends_on = [ azurerm_virtual_network.vnet ]            # Ensures the virtual_network is created before subnet
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = local.subnets[1].address_prefix
  depends_on = [ azurerm_virtual_network.vnet ]             # Ensures the virtual_network is created before subnet
}
