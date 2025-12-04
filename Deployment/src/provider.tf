terraform {
  required_version = ">= 1.3.0"

  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  # LOCAL: az login
  use_cli = true

  # PIPELINE: User Managed Identity
  use_msi         = true
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
