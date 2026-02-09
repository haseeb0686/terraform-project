
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}

  use_msi         = true
  subscription_id = "0a1809c0-b928-4863-a111-df91d6352856"
  tenant_id       = "189de737-c93a-4f5a-8b68-6f4ca9941912"

}