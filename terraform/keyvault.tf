resource "azurerm_key_vault" "kv" {
    location = azurerm_resource_group.cyclecloud.location
    name = "kv-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.cyclecloud.name
    sku_name = "standard"
    tenant_id = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days = 7

    purge_protection_enabled = false
    rbac_authorization_enabled = true
    public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "kv_pe" {
    location = azurerm_resource_group.networking.location
    name = "pe-${random_pet.naming.id}-kv"
    resource_group_name = azurerm_resource_group.networking.name
    subnet_id = azurerm_subnet.pe_subnet.id
    
    private_service_connection {
        is_manual_connection = false
        name = "kv-connection"
        private_connection_resource_id = azurerm_key_vault.kv.id
        subresource_names = ["vault"]
    }
    
    private_dns_zone_group {
      name = "${azurerm_key_vault.kv.name}-zone"
      private_dns_zone_ids = [ azurerm_private_dns_zone.kv_zone.id ]
    }
}

resource "azurerm_private_dns_zone" "kv_zone" {
    name = var.kv_pe_dns_zone
    resource_group_name = azurerm_resource_group.networking.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
    name = "${random_pet.naming.id}-kv-link"
    private_dns_zone_name = azurerm_private_dns_zone.kv_zone.name
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_id = azurerm_virtual_network.cc_network.id   
}

resource "azurerm_role_assignment" "kv_admin" {
    principal_id = data.azurerm_client_config.current.object_id
    scope = azurerm_key_vault.kv.id
    role_definition_id = "Key Vault Administrator"

    depends_on = [ azurerm_key_vault.kv ]
}

 resource "azurerm_key_vault_secret" "kv_private_key" {
    key_vault_id = azurerm_key_vault.kv.id
    name = "ssh-${random_pet.naming.id}-private-key"
    value_wo = ephemeral.tls_private_key.ssh_privatekey.private_key_openssh
    value_wo_version = 1

    depends_on = [ azurerm_role_assignment.kv_admin ]
 }

 resource "azurerm_key_vault_secret" "kv_public_key" {
    key_vault_id = azurerm_key_vault.kv.id
    name = "ssh-${random_pet.naming.id}-public-key"
    value_wo = ephemeral.tls_public_key.ssh_publickey.public_key_openssh
    value_wo_version = 1

    depends_on = [ azurerm_role_assignment.kv_admin ]
 }