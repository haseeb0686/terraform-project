
/*
module "rg" {
  source   = "./rg-module"
  rg_name  = "haseeb-rg"
  location = "South India"
}

module "vm" {

  source = "./vm"

  rg_name     = module.rg.resource_group_name
  rg_location = module.rg.resource_group_location
  vnet        = "haseb-vnet"
  subnet      = "haseeb-subnet"
  nic         = "nic"
  vm          = "hk-linuxvm"
  pip         = "pip-linuxvm"
  nsg_name    = "haseeb-nsg"

}

*/



data "azurerm_resource_group" "myrg" {
  name = "test-rg2"
}

output "id" {
  value = data.azurerm_resource_group.myrg.id
}

output "azurerm_public_ip" {
  value = azurerm_public_ip.pip[*].id
}



resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.myrg.location
  resource_group_name = data.azurerm_resource_group.myrg.name

  #depends_on = [ var.rg_name ]
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [azurerm_virtual_network.vnet]
}


resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = data.azurerm_resource_group.myrg.location
  resource_group_name = data.azurerm_resource_group.myrg.name

  security_rule {
    name                       = "ssh_allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}


resource "azurerm_subnet_network_security_group_association" "nsglink" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  
}


resource "azurerm_network_interface" "nic" {
  name                = "my-nic${count.index + 1}"
  location            = data.azurerm_resource_group.myrg.location
  resource_group_name = data.azurerm_resource_group.myrg.name

  count = 2

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id

    
  }
  #depends_on = [var.rg_name]   


}



resource "azurerm_public_ip" "pip" {
  name                = "my-pip${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.myrg.name
  location            = data.azurerm_resource_group.myrg.location
  sku                 = "Standard"
  allocation_method   = "Static"

  count = 2

  #depends_on = [ var.rg_name ]

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-001${count.index + 1}"
  resource_group_name             = data.azurerm_resource_group.myrg.name
  location                        = data.azurerm_resource_group.myrg.location
  size                            = "Standard_D2ds_v4"
  admin_username                  = "adminuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

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

  
  count = 2
  
}