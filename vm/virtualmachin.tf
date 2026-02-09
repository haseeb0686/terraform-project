
resource "azurerm_virtual_network" "vnet" {
  name                = "haseeb-${var.vnet}"
  address_space       = ["10.0.0.0/16"]
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_network_interface" "nic" {
  name                = "haseeb-${var.nic}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  depends_on = [ azurerm_subnet.subnet ]
  
}
  
  

resource "azurerm_public_ip" "pip" {
  name                = var.pip
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku                 = "Standard"  
  allocation_method   = "Static"

}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "haseeb-${var.vm}"
  resource_group_name = var.rg_name
  location            = var.rg_location
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