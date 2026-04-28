variable "location" {
  description = "Azure region to deploy resources in"
  type        = string
  default     = "southcentralus"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "bastion_subnet_space" {
  description = "Address space for the Azure Bastion subnet"
  type        = list(string)
  default     = ["10.100.0.0/26"]
}

variable "anf_subnet_space" {
  description = "Address space for the Azure NetApp Files subnet"
  type        = list(string)
  default     = ["10.100.0.64/26"]
}

variable "shared_subnet_space" {
  description = "Address space for the shared services subnet"
  type        = list(string)
  default     = ["10.100.0.128/27"]
}

variable "pe_subnet_space" {
  description = "Address space for the private endpoints subnet"
  type        = list(string)
  default     = ["10.100.0.160/28"]
}

variable "cc_subnet_space" {
  description = "Address space for the CycleCloud subnet"
  type        = list(string)
  default     = ["10.100.0.172/29"]
}

variable "cluster_subnet_space" {
  description = "Address space for the cluster subnet"
  type        = list(string)
  default     = ["10.100.2.0/23"]
}

variable "cc_vm_sku" {
  description = "CycleCloud recommends 4 cores and 8 GB of RAM for the VM"
  type        = string
  default     = "Standard_D4ads_v6"
}

variable "cc_username" {
  description = "Admin username for the CycleCloud VM"
  type        = string
  default     = "cyclecloudadmin"
}

variable "kv_pe_dns_zone" {
  description = "DNS zone for the key vault private endpoint"
  type        = string
  default     = "privatelink.vaultcore.azure.net"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    workload    = "cyclecloud"
    environment = "landing-zone"
    managed_by  = "terraform"
  }
}