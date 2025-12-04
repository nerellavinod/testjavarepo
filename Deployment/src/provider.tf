terraform {
  required_version = ">= 1.3.0"

  backend "azurerm" {
    resource_group_name  = "TempAugRG"
    storage_account_name = "tempaugstorage"
    container_name       = "tfstate"
    key                  = "hmnao.tfstate"
  }
}

provider "azurerm" {
  features {}
}
