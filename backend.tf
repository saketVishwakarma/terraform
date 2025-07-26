terraform {
  backend "azurerm" {
    resource_group_name  = "storage-group"
    storage_account_name = "demostorage12443"
    container_name       = "tfstates"
    key                  = "terraform.tfstate"
  }
}