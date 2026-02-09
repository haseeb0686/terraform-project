
resource "azurerm_resource_group" "rg" {
  name     = "haseeb-${var.rg_name}"
  location = var.location
}