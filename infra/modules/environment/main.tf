provider "azurerm" {
  features {}
}

variable "acr_name" {
  description = "Custom name for the Azure Container Registry. Must be globally unique and 5-50 alphanumeric characters."
  type        = string
}

variable "location" {
  description = "The location used for all deployed resources"
  type        = string
}

variable "tags" {
  description = "Tags that will be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "principal_id" {
  description = "Id of the user or app to assign application roles"
  type        = string
}

variable "environment_name" {
  description = "Environment name (e.g. dev, test, prod) used for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name     = "ess-managedidentity"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags     = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  tags                = var.tags
  admin_enabled       = false
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "ess-${var.environment_name}-insights-workspace"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "containerappenv" {
  name                = "ess-${var.environment_name}-containerappenv"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr_mi_role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.managed_identity.client_id
}

output "managed_identity_name" {
  value = azurerm_user
