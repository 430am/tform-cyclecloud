resource "random_pet" "ssh_key_name" {
    prefix = "ssh"
    separator = ""
}

resource "azapi_resource_action" "ssh_public_key_gen" {
    type = "Microsoft.Compute/sshPublicKeys@2025-04-01"
    resource_id = azapi_resource.ssh_public_key.id
    action = "generateKeyPair"
    method = "POST"

    response_export_values = [
        "publicKey",
        "privateKey"
    ]
}

resource "azapi_resource" "ssh_public_key" {
    type = "Microsoft.Compute/sshPublicKeys@2025-04-01"
    name = random_pet.ssh_key_name.id
    location = azurerm_resource_group.cyclecloud.location
    parent_id = azurerm_resource_group.cyclecloud.id
}

output "key_data" {
    value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}