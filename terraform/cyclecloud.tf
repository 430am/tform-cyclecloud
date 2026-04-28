resource "azurerm_network_interface" "cc_nic" {
    location = var.location
    name = "nic-${random_pet.naming.id}-cc"
    resource_group_name = azurerm_resource_group.cyclecloud.name
    ip_configuration {
        name = "internal"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.cc_subnet.id
    }
}

data "cloudinit_config" "cc_config" {
    gzip = true
    base64_encode = true
    part {
        content_type = "text/cloud-config"
        content = file("${path.module}/files/cc-config.yaml")
    }
}

resource "azurerm_linux_virtual_machine" "cc_vm" {
    location = var.location
    name = "vm-${random_pet.naming.id}-cc"
    network_interface_ids = [azurerm_network_interface.cc_nic.id]
    resource_group_name = azurerm_resource_group.cyclecloud.name
    size = var.cc_vm_sku
    
    identity {
      type = "SystemAssigned"
    }
    
    os_disk {
        name = "osdisk-${random_pet.naming.id}-cc"
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb = 256
    }
    
    source_image_reference {
      publisher = "Canonical"
      offer = "ubuntu-24_04-lts"
      sku = "server"
      version = "latest"
    }

    admin_username = var.cc_username

    admin_ssh_key {
      username = var.cc_username
      public_key = data.azurerm_key_vault_secret.kv_public_key.value
    }

    user_data = filebase64("${path.module}/files/cc-config.yaml")
}

resource "azurerm_role_assignment" "cc_vm_role" {
    principal_id = azurerm_linux_virtual_machine.cc_vm.identity[0].principal_id
    scope = data.azurerm_subscription.current.id
    role_definition_id = azurerm_linux_virtual_machine.cc_vm.identity[0].principal_id

    depends_on = [ azurerm_role_definition.ccrole ]
}

resource "azurerm_role_assignment" "cc_vm_locker_access" {
    principal_id = azurerm_linux_virtual_machine.cc_vm.identity[0].principal_id
    scope = azurerm_storage_account.cc_locker.id
    role_definition_id = azurerm_role_definition.ccrole.id

    depends_on = [ azurerm_role_definition.ccrole, azurerm_storage_account.cc_locker ]
}

resource "azurerm_storage_account" "cc_locker" {
    account_replication_type = "LRS"
    account_tier = "StorageV2"
    location = azurerm_resource_group.cyclecloud.location
    name = "st${random_pet.naming.id}locker"
    resource_group_name = azurerm_resource_group.cyclecloud.name
}

resource "azurerm_private_endpoint" "cc_locker_pe" {
    location = azurerm_resource_group.networking.location
    name = "pe-${random_pet.naming.id}-cc-locker"
    resource_group_name = azurerm_resource_group.networking.name
    subnet_id = azurerm_subnet.pe_subnet.id
    
    private_service_connection {
        is_manual_connection = false
        name = "cc-locker-connection"
        private_connection_resource_id = azurerm_storage_account.cc_locker.id
        subresource_names = ["blob"]
    }
    
    private_dns_zone_group {
      name = "${azurerm_storage_account.cc_locker.name}-zone"
      private_dns_zone_ids = [ azurerm_private_dns_zone.storage_zone.id ]
    }
}

resource "azurerm_private_dns_zone" "storage_zone" {
    name = var.storage_pe_dns_zone
    resource_group_name = azurerm_resource_group.networking.name    
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_link" {
    name = "${random_pet.naming.id}-storage-link"
    private_dns_zone_name = azurerm_private_dns_zone.storage_zone.name
    resource_group_name = azurerm_resource_group.networking.name
    virtual_network_id = azurerm_virtual_network.cc_network.id
    
}