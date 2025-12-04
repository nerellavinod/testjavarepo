variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "app_service_name" {
  type = string
}

variable "address_space" {
  default = ["10.50.0.0/16"]
}

variable "subnet_web" {
  default = "10.50.1.0/24"
}

variable "subnet_pe" {
  default = "10.50.2.0/24"
}
