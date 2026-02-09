

module "rg" {
  source = "./rg-module"
  rg_name = "myrg-01"
  location = "South India"
}

module "vm" {

  source = "./vm"

  rg_name = module.rg.resource_group_name
  rg_location = module.rg.resource_group_location
  vnet = "vnet"
  subnet = "subnet"
  nic = "nic"
  vm = "linuxvm"
  pip = "pip-linuxvm"
  
}