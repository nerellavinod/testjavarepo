output "webapp_url" {
  value = azurerm_linux_web_app.webapp.default_hostname
}

output "keyvault_name" {
  value = azurerm_key_vault.kv.name
}
