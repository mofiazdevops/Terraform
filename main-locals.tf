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

}

resource "azurerm_subnet" "subnetA" {           # Now Create sperate subnet_block
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = local.subnets[0].address_prefix
  depends_on = [ azurerm_virtual_network.vnet ]            # Ensures the virtual_network is created after subnet
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = local.subnets[1].address_prefix
  depends_on = [ azurerm_virtual_network.vnet ]             # Ensures the virtual_network is created after subnet
}

resource "azurerm_network_interface" "NIC" {
  name                = "nafi-nic"
  location            = local.location                  # Rigion location
  resource_group_name = local.resource_group_name       # Pick automatically resource group from locals 

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = azurerm_subnet.subnetA.id   # Select subnet where you want to create NIC 
    private_ip_address_allocation = "Dynamic"                    # Assing private_ip 
    public_ip_address_id = azurerm_public_ip.publicip1.id        # This field purpose is to attach public/private_ip with NIC
  }
  depends_on = [ azurerm_subnet.subnetA]                       # Ensures the NIC is created after subnet          
}

resource "azurerm_public_ip" "publicip1" {
  name                = "demoPublicIp"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
  depends_on = [ azurerm_resource_group.RG ]           # Ensures the Resource_group is created after Public_IP
}

resource "azurerm_network_security_group" "NSG" {
  name                = "Al-nafi-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"                # it means anywhere of the world 
    destination_port_range     = "22,80"            # Allow port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Al-nafi"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "demo-server"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.NIC.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("home/codespace/.ssh/id_rsa.pub")          # Path where our ssh_key file are exsist 
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  depends_on = [ azurerm_network_interface.NIC,azurerm_resource_group.RG ] 
}
