locals {
  resource_group_name = "Tayyba"
  location = "East Asia"
  virtual_network={                              
    name = "al-nafi-net"
    address_space = "10.0.0.0/16"
  }
}
