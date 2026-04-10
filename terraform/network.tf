resource "azurerm_public_ip" "bastion-ip" {
    allocation_method = "Static"
    location = var.location
    name = var.bastion_public_ip_name
    resource_group_name = var.resource_group_name
    sku = "Standard"
}

resource "azurerm_public_ip" "nat-ip" {
    allocation_method = "Static"
    location = var.location
    name = var.nat_public_ip_name
    resource_group_name = var.resource_group_name
    sku = "Standard"
}

resource "azurerm_virtual_network" "cc-network" {
    location = var.location
    name = var.vnet_name
    resource_group_name = var.resource_group_name
    address_space = var.vnet_address_space
}

resource "azurerm_subnet" "bastion-subnet" {
    name = "AzureBastionSubnet"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes = var.bastion_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "anf-subnet" {
    name = "0-storage"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes = var.anf_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "shared-subnet" {
    name = "1-shared"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes = var.shared_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "pe-subnet" {
    name = "2-privateendpoints"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes = var.pe_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "cc-subnet" {
    name = "3-cyclecloud"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes = var.cc_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "cluster-subnet" {
    name = "4-clusters"
    resource_group_name = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes = var.cluster_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_bastion_host" "cc-bastion" {
    location = var.location
    name = "bas-cyclecloud"
    resource_group_name = var.resource_group_name
    sku = "Standard"
    copy_paste_enabled = true
    tunneling_enabled = true

    ip_configuration {
        name = "bastion-ip-config"
        subnet_id = azurerm_subnet.bastion-subnet.id
        public_ip_address_id = azurerm_public_ip.bastion-ip.id
    }
}

resource "azurerm_nat_gateway" "cc-nat" {
    location = var.location
    name = "nat-cyclecloud"
    resource_group_name = var.resource_group_name
    sku_name = "Standard"    
}

resource "azurerm_nat_gateway_public_ip_association" "pip-nat" {
    nat_gateway_id = azurerm_nat_gateway.cc-nat.id
    public_ip_address_id = azurerm_public_ip.nat-ip.id    
}

resource "azurerm_subnet_nat_gateway_association" "cc-nat-assoc" {
    nat_gateway_id = azurerm_nat_gateway.cc-nat.id
    subnet_id = azurerm_subnet.cc-subnet.id    
}

resource "azurerm_subnet_nat_gateway_association" "cluster-nat-assoc" {
    nat_gateway_id = azurerm_nat_gateway.cc-nat.id
    subnet_id = azurerm_subnet.cluster-subnet.id    
}