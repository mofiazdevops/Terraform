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
  name                = "al-nafi-net"
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "Custome-subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "Custome-subnet2"          # Name of the subnet
    address_prefixes = ["10.0.2.0/24"]             # CIDR block defining the subnet range 
  }
    depends_on = [ azurerm_resource_group.RG ]   # Ensures the resource group is created before this subnet

  tags = {
    environment = "Production"
  }
}
