resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${local.env_name}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.webapp_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_app_service_plan.plan.id
  site_config {
    always_on = false
    linux_fx_version = "NODE|20-lts"
  }
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "true"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}
