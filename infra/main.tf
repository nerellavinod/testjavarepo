provider "azurerm" {
  features {}
}

variable "location" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "principal_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment_name}"
  location = var.location
}

module "environment" {
  source             = "./modules/environment"
  acr_name           = var.acr_name
  location           = var.location
  tags               = var.tags
  principal_id       = var.principal_id
  environment_name   = var.environment_name
  resource_group_name = azurerm_resource_group.rg.name
}
