
terraform {
  backend "azurerm" {
    resource_group_name  = "haseeb"
    storage_account_name = "haseebstorage08061986"
    container_name       = "myremotebackend"
    key                  = "uat.terraform.tfstate"
    use_azuread_auth     = true
  }
}