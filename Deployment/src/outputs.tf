output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "app_service_name" {
  value = azurerm_app_service.main.name
}

output "app_service_default_hostname" {
  value = azurerm_app_service.main.default_site_hostname
}
