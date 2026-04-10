resource "azurerm_network_interface" "cc-nic" {
    location = var.location
    name = "nic-cyclecloud"
    resource_group_name = var.resource_group_name
    ip_configuration {
        name = "internal"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.cc-subnet.id
    }
}

resource "azurerm_linux_virtual_machine" "cc-vm" {
    location = var.location
    name = "vm-cyclecloud"
    network_interface_ids = [azurerm_network_interface.cc-nic.id]
    resource_group_name = var.resource_group_name
    size = var.cc_vm_sku
    
    os_disk {
        name = "cc-vm-osdisk"
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb = 256
    }
    
    source_image_reference {
      publisher = "microsoft-dsvm"
      offer = "ubuntu-hpc"
      sku = "2404"
      version = "latest"
    }

    admin_username = var.cc_username

    admin_ssh_key {
      username = var.cc_username
      public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
}