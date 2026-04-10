terraform {
  required_version = ">= 0.13.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 4.68.0"
    }
    random = {
        source = "hashicorp/random"
        version = ">= 3.8.0"
    }
    azapi = {
        source = "azure/azapi"
        version = ">= 2.9.0"
    }
  }
}
