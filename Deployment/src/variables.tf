variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "c3d246d3-988a-45ae-ba70-f7faac1e2d0a"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "tempaugrg"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "uksouth"
}

variable "storage_account_name" {
  description = "Storage account name for Terraform state and app"
  type        = string
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
}

variable "app_service_name" {
  description = "App Service name"
  type        = string
}
