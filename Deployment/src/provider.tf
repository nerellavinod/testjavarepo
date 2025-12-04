terraform {
  required_version = ">= 1.3.0"

  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  # LOCAL MACHINE (VS Code)
  # Terraform automatically uses az login
  skip_provider_registration = false

  # AZURE DEVOPS (Managed Identity)
  use_msi         = true
  client_id       = var.client_id
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
