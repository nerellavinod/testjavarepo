terraform {
  required_version = ">= 1.3.0"

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}
