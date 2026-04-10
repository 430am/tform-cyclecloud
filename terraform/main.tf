data "azurerm_subscription" "current" {
}

resource "random_string" "random" {
    length = 6
    special = false
    upper = false    
}

resource "azurerm_resource_group" "cyclecloud" {
    location = var.location
    name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "cyclecloud-id" {
    location = azurerm_resource_group.cyclecloud.location
    name = var.managed_identity_name
    resource_group_name = azurerm_resource_group.cyclecloud.name
}

resource "azurerm_role_definition" "ccrole" {
    name = "CycleCloud Orchestration Role"
    scope = data.azurerm_subscription.current.id
    description = "This is a custom role designed to provide the identities for CycleCloud with least privileged access to perform cluster orchestration"
    
    permissions {
        actions = [
          "Microsoft.Authorization/*/read",
          "Microsoft.Authorization/roleAssignments/*",
          "Microsoft.Authorization/roleDefinitions/*",
          "Microsoft.Commerce/RateCard/read",
          "Microsoft.Compute/*/read",
          "Microsoft.Compute/availabilitySets/*",
          "Microsoft.Compute/disks/*",
          "Microsoft.Compute/images/read",
          "Microsoft.Compute/locations/usages/read",
          "Microsoft.Compute/register/action",
          "Microsoft.Compute/skus/read",
          "Microsoft.Compute/virtualMachines/*",
          "Microsoft.Compute/virtualMachineScaleSets/*",
          "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/*",
          "Microsoft.ManagedIdentity/userAssignedIdentities/*/read",
          "Microsoft.ManagedIdentity/userAssignedIdentities/*/assign/action",
          "Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/read",
          "Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/write",
          "Microsoft.Network/*/read",
          "Microsoft.Network/locations/*/read",
          "Microsoft.Network/networkInterfaces/read",
          "Microsoft.Network/networkInterfaces/write",
          "Microsoft.Network/networkInterfaces/delete",
          "Microsoft.Network/networkInterfaces/join/action",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Network/networkSecurityGroups/write",
          "Microsoft.Network/networkSecurityGroups/delete",
          "Microsoft.Network/networkSecurityGroups/join/action",
          "Microsoft.Network/publicIPAddresses/read",
          "Microsoft.Network/publicIPAddresses/write",
          "Microsoft.Network/publicIPAddresses/delete",
          "Microsoft.Network/publicIPAddresses/join/action",
          "Microsoft.Network/register/action",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/subnets/read",
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Resources/deployments/read",
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.Resources/subscriptions/resourceGroups/write",
          "Microsoft.Resources/subscriptions/resourceGroups/delete",
          "Microsoft.Resources/subscriptions/resourceGroups/resources/read",
          "Microsoft.Resources/subscriptions/operationresults/read",
          "Microsoft.Storage/*/read",
          "Microsoft.Storage/checknameavailability/read",
          "Microsoft.Storage/register/action",
          "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
          "Microsoft.Storage/storageAccounts/blobServices/containers/read",
          "Microsoft.Storage/storageAccounts/blobServices/containers/write",
          "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action",
          "Microsoft.Storage/storageAccounts/read",
          "Microsoft.Storage/storageAccounts/listKeys/action",
          "Microsoft.Storage/storageAccounts/write"
        ]
        data_actions = [        
          "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
          "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
          "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
          "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/move/action",
          "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
        ]
        not_actions = []
        not_data_actions = []
    }

    assignable_scopes = [ data.azurerm_subscription.current.id ]
}

resource "azurerm_role_assignment" "ccid-roleassignment" {
    principal_id = azurerm_user_assigned_identity.cyclecloud-id.principal_id
    scope = data.azurerm_subscription.current.id
    role_definition_id = azurerm_role_definition.ccrole.role_definition_resource_id
}

