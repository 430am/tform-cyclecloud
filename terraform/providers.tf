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
    tls = {
        source = "hashicorp/tls"
        version = ">= 4.2.1"
    }
    cloudinit = {
        source = "hashicorp/cloudinit"
        version = ">= 2.3.7"
    }
  }
}

provider "azurerm" {
  features {}
}