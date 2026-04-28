# Azure CycleCloud Infrastructure Deployment

Automated Terraform configuration for deploying a complete Azure CycleCloud Application Server environment with enterprise-grade networking and security.

## Overview

This Terraform project provisions a fully-featured CycleCloud infrastructure on Azure with an opinionated network design optimized for HPC cluster management. It creates all necessary compute, storage, networking, and identity resources in a secure, production-ready configuration.

### What Gets Deployed

#### Networking
- **Azure Virtual Network** (10.100.0.0/16)
- **Subnets** with segmented purposes:
  - Bastion subnet (/26) - Azure Bastion host
  - Azure NetApp Files subnet (/26) - NFS storage
  - Shared services subnet (/27) - Shared infrastructure
  - Private endpoints subnet (/28) - Storage and Key Vault endpoints
  - CycleCloud app server subnet (/29) - CycleCloud VM
  - Cluster subnet (/23) - HPC compute nodes
- **Azure NAT Gateway** - Outbound connectivity for VMs

#### Compute & Storage
- **CycleCloud Application Server** - Linux VM with managed identity
- **Azure Storage Account** - CycleCloud Locker for cluster definitions
- **Azure NetApp Files** - High-performance NFS storage for cluster data
- **Azure Bastion** - Secure RDP/SSH access to VMs

#### Security & Identity
- **User-Assigned Managed Identity** - For CycleCloud service authentication
- **Custom CycleCloud Orchestration Role** - Least-privilege access for cluster operations
- **Azure Key Vault** - Secure storage for SSH keys and secrets
- **Private Endpoints** - Secure connectivity to Storage Account and Key Vault

## Prerequisites

- **Terraform** >= 0.13.0 (tested with latest versions)
- **Azure CLI** authenticated to your subscription
- **Required Terraform Providers**:
  - azurerm >= 4.68.0
  - random >= 3.8.0
  - tls >= 4.2.1
  - cloudinit >= 2.3.7

## Quick Start

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd tform-cyclecloud/terraform
```

### 2. Configure Variables (Optional)

Create a `terraform.tfvars` file to override defaults:

```hcl
location              = "eastus"
vnet_address_space    = ["10.0.0.0/16"]
cc_vm_sku            = "Standard_D4s_v3"
```

See [Configuration Variables](#configuration-variables) below for all available options.

### 3. Initialize and Review Plan

```bash
terraform init
terraform plan -out=tfplan
```

Review the planned resources carefully before applying.

### 4. Deploy Infrastructure

```bash
terraform apply tfplan
```

The deployment typically takes 10-15 minutes. Terraform will output important resource IDs and connection details.

### 5. Access CycleCloud

After deployment completes:
1. Retrieve the CycleCloud VM's public IP from the terraform outputs
2. Use Azure Bastion to connect securely
3. Initialize CycleCloud through its web interface (default port 8080)
4. The CycleCloud admin password is stored in Azure Key Vault

## Configuration Variables

Key variables to customize your deployment:

| Variable | Default | Description |
|----------|---------|-------------|
| `location` | southcentralus | Azure region for all resources |
| `vnet_address_space` | 10.100.0.0/16 | VNet address space |
| `cc_vm_sku` | Standard_D4s_v3 | VM SKU for CycleCloud app server (min 4 cores, 8GB RAM) |
| `cluster_subnet_space` | 10.100.2.0/23 | Subnet for HPC cluster compute nodes |
| `bastion_subnet_space` | 10.100.0.0/26 | Subnet for Azure Bastion |
| `anf_subnet_space` | 10.100.0.64/26 | Subnet for Azure NetApp Files |
| `shared_subnet_space` | 10.100.0.128/27 | Shared services subnet |
| `pe_subnet_space` | 10.100.0.160/28 | Private endpoints subnet |
| `cc_subnet_space` | 10.100.0.172/29 | CycleCloud app server subnet |

For complete list of variables, see [terraform/variables.tf](terraform/variables.tf).

## Project Structure

```
terraform/
├── main.tf              # Core resource definitions
├── network.tf           # Virtual network and subnets
├── cyclecloud.tf        # CycleCloud VM and configuration
├── keyvault.tf          # Key Vault and secrets management
├── locals.tf            # Local values and computed variables
├── outputs.tf           # Output values for deployed resources
├── providers.tf         # Provider configuration and requirements
├── variables.tf         # Variable definitions and defaults
└── files/               # Configuration and initialization files
    ├── 0_ms_keys.sh     # Microsoft Enterprise Linux setup
    ├── 1_cc-config.yaml # CycleCloud configuration template
    └── cc_cli.sh        # CycleCloud CLI setup script
```

## Deployment Outputs

After successful deployment, Terraform outputs include:

- **CycleCloud VM ID and IP addresses**
- **Key Vault reference** for accessing secrets
- **Storage Account information** for the CycleCloud Locker
- **Azure NetApp Files export paths**
- **Subnet and VNet details** for cluster configuration

View outputs at any time:
```bash
terraform output
```

## Managing the Deployment

### Update Deployment

Modify variables and reapply:
```bash
terraform plan
terraform apply
```

### Destroy Resources

To clean up all deployed resources:
```bash
terraform destroy
```

⚠️ **Warning**: This will delete all resources including data storage. Ensure data backups are complete before destroying.

## Security Considerations

- **Private Endpoints** used for Storage Account and Key Vault to avoid internet exposure
- **Managed Identity** provides secure, credential-free authentication for CycleCloud
- **Custom RBAC Role** follows principle of least privilege for cluster operations
- **SSH Keys** automatically generated and stored securely in Key Vault
- **Azure Bastion** provides secure access without exposing VMs to the internet
- **NAT Gateway** provides secure outbound connectivity with static IPs

## Troubleshooting

### Deployment Fails During VM Creation
- Verify VM SKU is available in your region: `az vm list-skus --location <region>`
- Ensure sufficient quota for VMs, disks, and vCPUs in your subscription

### Cannot Connect to CycleCloud
- Verify Azure Bastion is deployed and running
- Check Network Security Group rules if using custom networking
- Confirm CycleCloud VM is in Running state in Azure Portal

### Terraform State Issues
- Ensure terraform state files are not committed to git
- Use Azure storage account for remote state in shared environments
- Back up local state files regularly

## Additional Resources

- [CycleCloud Documentation](https://learn.microsoft.com/en-us/azure/cyclecloud/)
- [CycleCloud Managed Identities](https://learn.microsoft.com/en-us/azure/cyclecloud/how-to/managed-identities?view=cyclecloud-8)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CycleCloud Best Practices](https://learn.microsoft.com/en-us/azure/cyclecloud/concepts/best-practices)

## License

This Terraform configuration is provided as-is for Azure CycleCloud deployments.