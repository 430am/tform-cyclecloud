variable "location" {
  description = "Azure region to deploy resources in"
  type        = string
  default     = "southcentralus"
}

variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  default     = "rg-cyclecloud"
}

variable "managed_identity_name" {
  description = "Name of the user assigned managed identity to create"
  type        = string
  default     = "cyclecloud-id"
}

variable "nat_public_ip_name" {
  description = "Name of the public IP to create for NAT gateway"
  type        = string
  default     = "pip-natgateway"
}

variable "bastion_public_ip_name" {
  description = "Name of the public IP to create for Azure Bastion"
  type        = string
  default     = "pip-bastion"
}

variable "vnet_name" {
  description = "Name of the virtual network to create"
  type        = string
  default     = "vnet-cyclecloud"
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
