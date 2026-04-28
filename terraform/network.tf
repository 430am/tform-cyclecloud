resource "azurerm_public_ip" "bastion_ip" {
    allocation_method = "Static"
    location = var.location
    name = "pip-${random_pet.naming.id}-bastion"
    resource_group_name = azurerm_resource_group.networking
    sku = "Standard"
    tags = local.common_tags
}

resource "azurerm_public_ip" "nat_ip" {
    allocation_method = "Static"
    location = var.location
    name = "pip-${random_pet.naming.id}-nat"
    resource_group_name = azurerm_resource_group.networking.name
    sku = "Standard"
    tags = local.common_tags
}

resource "azurerm_virtual_network" "cc_network" {
    location = var.location
    name = "vnet-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.networking.name
    address_space = var.vnet_address_space
}

resource "azurerm_subnet" "bastion_subnet" {
    name = "AzureBastionSubnet"
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_name = azurerm_virtual_network.cc_network.name
    address_prefixes = var.bastion_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "anf_subnet" {
    name = "0-storage"
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_name = azurerm_virtual_network.cc_network.name
    address_prefixes = var.anf_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "shared_subnet" {
    name = "1-shared"
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_name = azurerm_virtual_network.cc_network.name
    address_prefixes = var.shared_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "pe_subnet" {
    name = "2-privateendpoints"
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_name = azurerm_virtual_network.cc_network.name
    address_prefixes = var.pe_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "cc_subnet" {
    name = "3-cyclecloud"
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_name = azurerm_virtual_network.cc_network.name
    address_prefixes = var.cc_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "cluster_subnet" {
    name = "4-clusters"
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_name = azurerm_virtual_network.cc_network.name
    address_prefixes = var.cluster_subnet_space
    default_outbound_access_enabled = false
}

resource "azurerm_bastion_host" "cc_bastion" {
    location = var.location
    name = "bastion-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.networking.name
    sku = "Standard"
    copy_paste_enabled = true
    tunneling_enabled = true

    ip_configuration {
        name = "${azurerm_bastion_host.cc_bastion.name}-ipconfig"
        subnet_id = azurerm_subnet.bastion_subnet.id
        public_ip_address_id = azurerm_public_ip.bastion_ip.id
    }
}

resource "azurerm_nat_gateway" "cc_nat" {
    location = var.location
    name = "nat-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.networking.name
    sku_name = "Standard"    
}

resource "azurerm_nat_gateway_public_ip_association" "pip_nat" {
    nat_gateway_id = azurerm_nat_gateway.cc_nat.id
    public_ip_address_id = azurerm_public_ip.nat_ip.id    
}

resource "azurerm_subnet_nat_gateway_association" "cc_nat_assoc" {
    nat_gateway_id = azurerm_nat_gateway.cc_nat.id
    subnet_id = azurerm_subnet.cc_subnet.id    
}

resource "azurerm_subnet_nat_gateway_association" "cluster_nat_assoc" {
    nat_gateway_id = azurerm_nat_gateway.cc_nat.id
    subnet_id = azurerm_subnet.cluster_subnet.id    
}
