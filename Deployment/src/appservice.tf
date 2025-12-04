resource "azurerm_service_plan" "plan" {
  name                = "hmnao-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "${var.app_service_name}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    linux_fx_version = "NODE|20-lts"
  }

  identity {
    type = "SystemAssigned"
  }
}
