

data "azurerm_resource_group" "myrg" {
  name = "test-rg"
}

output "id" {
  value = data.azurerm_resource_group.myrg.id
}



resource "azurerm_virtual_network" "vnet" {
  name                = var.vm
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

  depends_on = [ azurerm_virtual_network.vnet ]
}


resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
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
  name                ="my-nic"
  location            = data.azurerm_resource_group.myrg.location
  resource_group_name = data.azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  #depends_on = [var.rg_name]   
 
  
}
  
  

resource "azurerm_public_ip" "pip" {
  name                = "my-pip"
  resource_group_name = data.azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  sku                 = "Standard"  
  allocation_method   = "Static"

  #depends_on = [ var.rg_name ]

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-001"
  resource_group_name = data.azurerm_resource_group.myrg.name
  location            = data.azurerm_resource_group.myrg.location
  size                = "Standard_D2ds_v4"
  admin_username      = "adminuser"
  admin_password      = "Password1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
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




  

}