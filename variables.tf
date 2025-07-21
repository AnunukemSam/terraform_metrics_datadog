variable "location" {
  default = "West Europe"
}

variable "resource_group_name" {
  default = "aks-devops-rg"
}

variable "vnet_name" {
  default = "aks-vnet"
}

variable "subnet_name" {
  default = "aks-subnet"
}

variable "datadog_api_key" {
  description = "Datadog API key"
  sensitive   = true
}
