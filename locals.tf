locals {
  resource_group_name = "Tayyba"
  location = "East Asia"
  virtual_network={                              
    name = "al-nafi-net"
    address_space = "10.0.0.0/16"
  }
  subnets = [
    {
      name = "Custome-subnet1"
      address_prefix = ["10.0.1.0/24"]
    },
    {
      name = "Custome-subnet2"
      address_prefix = ["10.0.2.0/24"]
    }
  ]
}
