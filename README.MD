## Automated deployment of CycleCloud Application Server using Terraform ##

This is an opinionated build for CycleCloud and includes the following:

 - Azure Virtual Network deployment
 - Subnet definitions the way I like them:
    - Subnet for shared services /27
    - Subnet for CycleCloud app server /29
    - Subnet for private endpoints /28
    - Subnet for Azure NetApp Files /26
    - Subnet for Azure Bastion /26
    - Subnet for clusters /23
 - The following Azure resources will be deployed:
    - Azure NAT Gateway
    - Linux VM - CycleCloud app server
    - Azure Storage Account - CycleCloud Locker
    - User Defined Managed Identity
    - Azure NetApp Files
    - Azure Bastion
    - Azure Key Vault
 - Custom Role created for CycleCloud Operaations [read more here](https://learn.microsoft.com/en-us/azure/cyclecloud/how-to/managed-identities?view=cyclecloud-8)
 - Private Endpoints will be used for Storage Account and Key Vault
 - an SSH key will be created for the cluster and stored in Azure

It's a work in progress, so bear with me.